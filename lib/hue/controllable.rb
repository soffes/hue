module Hue
  module Controllable
    HUE_RANGE = 0..65535
    SATURATION_RANGE = 0..255
    BRIGHTNESS_RANGE = 0..255
    COLOR_TEMPERATURE_RANGE = 153..500

    # Unique identification number.
    attr_reader :id

    # Bridge the entity is associated with
    attr_reader :bridge

    # A unique, editable name given to the entity.
    attr_accessor :name

    # Hue of the entity. This is a wrapping value between 0 and 65535.
    # Both 0 and 65535 are red, 25500 is green and 46920 is blue.
    attr_accessor :hue

    # Saturation of the entity. 255 is the most saturated (colored)
    # and 0 is the least saturated (white).
    attr_accessor :saturation

    # Brightness of the entity. This is a scale from the minimum
    # brightness the entity is capable of, 0, to the maximum capable
    # brightness, 255. Note a brightness of 0 is not off.
    attr_accessor :brightness

    # The x coordinate of a color in CIE color space. Between 0 and 1.
    #
    # @see http://developers.meethue.com/coreconcepts.html#color_gets_more_complicated
    attr_reader :x

    # The y coordinate of a color in CIE color space. Between 0 and 1.
    #
    # @see http://developers.meethue.com/coreconcepts.html#color_gets_more_complicated
    attr_reader :y

    # The Mired Color temperature of the entity. 2012 connected entitys
    # are capable of 153 (6500K) to 500 (2000K).
    #
    # @see http://en.wikipedia.org/wiki/Mired
    attr_accessor :color_temperature

    # The alert effect, which is a temporary change to the entity's state.
    # This can take one of the following values:
    # * `none` – The entity is not performing an alert effect.
    # * `select` – The entity is performing one breathe cycle.
    # * `lselect` – The entity is performing breathe cycles for 30 seconds
    #     or until an "alert": "none" command is received.
    #
    # Note that in version 1.0 this contains the last alert sent to the
    # entity and not its current action. This will be changed to contain the
    # current action in an upcoming patch.
    #
    # @see http://developers.meethue.com/coreconcepts.html#some_extra_fun_stuff
    attr_accessor :alert

    # The dynamic effect of the entity, can either be `none` or
    # `colorloop`. If set to colorloop, the entity will cycle through
    # all hues using the current brightness and saturation settings.
    attr_accessor :effect

    def initialize(client, bridge, id, hash)
      @client = client
      @bridge = bridge
      @id = id
      unpack(hash)
    end

    def name=(new_name)
      unless (1..32).include?(new_name.length)
        raise InvalidValueForParameter, 'name must be between 1 and 32 characters.'
      end

      body = {
        :name => new_name
      }

      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.host)
      response = http.request_put(uri.path, MultiJson.dump(body))
      response = MultiJson.load(response.body).first
      if response['success']
        @name = new_name
      # else
        # TODO: Error
      end
    end

    %w{on hue saturation brightness color_temperature}.each do |key|
      define_method "#{key}=".to_sym do |value|
        set_state({key.to_sym => value})
        instance_variable_set("@#{key}".to_sym, value)
      end
    end

    def set_xy(x, y)
      set_state({:xy => [x, y]})
      @x, @y = x, y
    end

    # @param transition The duration of the transition from the entity’s current
    #   state to the new state. This is given as a multiple of 100ms and
    #   defaults to 4 (400ms). For example, setting transistiontime:10 will
    #   make the transition last 1 second.
    def set_state(attributes, transition = nil)
      body = translate_keys(attributes)

      # Add transition
      body.merge!({:transitiontime => transition}) if transition

      uri = URI.parse("#{base_url}/#{self.class.const_get(:STATE_PATH)}")
      http = Net::HTTP.new(uri.host)
      response = http.request_put(uri.path, MultiJson.dump(body))
      MultiJson.load(response.body)
    end

    # Refresh the state of the entity
    # Note that it's not possible to retrieve the current state of a group,
    # only the last state that was sent to the entire group.
    def refresh
      json = MultiJson.load(Net::HTTP.get(URI.parse(base_url)))
      unpack(json)
    end

    def translate_keys(hash)
      new_hash = {}
      hash.each do |key, value|
        new_key = self.class.const_get(:STATE_KEYS_MAP)[key.to_sym]
        key = new_key if new_key
        new_hash[key] = value
      end
      new_hash
    end

    def unpack(hash)
      unpack_hash(hash, self.class.const_get(:KEYS_MAP))
      unpack_hash(@state, self.class.const_get(:STATE_KEYS_MAP))
    end

    def unpack_hash(hash, map)
      map.each do |local_key, remote_key|
        value = hash[remote_key.to_s]
        next unless value
        instance_variable_set("@#{local_key}", value)
      end
    end
  end
end
