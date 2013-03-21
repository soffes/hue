module Hue
  class Light
    HUE_RANGE = 0..65535
    SATURATION_RANGE = 0..255
    BRIGHTNESS_RANGE = 0..255
    COLOR_TEMPERATURE_RANGE = 153..500

    # Unique identification number.
    attr_reader :id

    # A unique, editable name given to the light.
    attr_accessor :name

    # Hue of the light. This is a wrapping value between 0 and 65535.
    # Both 0 and 65535 are red, 25500 is green and 46920 is blue.
    attr_accessor :hue

    # Saturation of the light. 255 is the most saturated (colored)
    # and 0 is the least saturated (white).
    attr_accessor :saturation

    # Brightness of the light. This is a scale from the minimum
    # brightness the light is capable of, 0, to the maximum capable
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

    # The Mired Color temperature of the light. 2012 connected lights
    # are capable of 153 (6500K) to 500 (2000K).
    #
    # @see http://en.wikipedia.org/wiki/Mired
    attr_accessor :color_temperature

    # The alert effect, which is a temporary change to the bulb’s state.
    # This can take one of the following values:
    # * `none` – The light is not performing an alert effect.
    # * `select` – The light is performing one breathe cycle.
    # * `lselect` – The light is performing breathe cycles for 30 seconds
    #     or until an "alert": "none" command is received.
    #
    # Note that in version 1.0 this contains the last alert sent to the
    # light and not its current state. This will be changed to contain the
    # current state in an upcoming patch.
    #
    # @see http://developers.meethue.com/coreconcepts.html#some_extra_fun_stuff
    attr_accessor :alert

    # The dynamic effect of the light, can either be `none` or
    # `colorloop`. If set to colorloop, the light will cycle through
    # all hues using the current brightness and saturation settings.
    attr_accessor :effect

    # Indicates the color mode in which the light is working, this is
    # the last command type it received. Values are `hs` for Hue and
    # Saturation, `xy` for XY and `ct` for Color Temperature. This
    # parameter is only present when the light supports at least one
    # of the values.
    attr_reader :color_mode

    # A fixed name describing the type of light.
    attr_reader :type

    # The hardware model of the light.
    attr_reader :model

    # An identifier for the software version running on the light.
    attr_reader :software_version

    # Reserved for future functionality.
    attr_reader :point_symbol

    def initialize(client, id, name)
      @client = client
      @id = id
      @name = name
      refresh
    end

    def [](index)
      lights[index]
    end

    def name=(new_name)
      unless (1..32).include?(new_name.length)
        raise InvalidValueForParameter, 'name must be between 1 and 32 characters.'
      end

      body = {
        :name => new_name
      }

      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.hostname)
      response = http.request_put(uri.path, MultiJson.dump(body))
      response = MultiJson.load(response.body).first
      if response['success']
        @name = new_name
      # else
        # TODO: Error
      end
    end

    def on?
      @state['on']
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

    # Indicates if a light can be reached by the bridge. Currently
    # always returns true, functionality will be added in a future
    # patch.
    def reachable?
      @state['reachable']
    end

    # @param transition The duration of the transition from the light’s current
    #   state to the new state. This is given as a multiple of 100ms and defaults
    #   to 4 (400ms). For example, setting transistiontime:10 will make the
    #   transition last 1 second.
    def set_state(attributes, transition = nil)
      map = {
        :brightness => :bri,
        :saturation => :sat,
        :color_temperature => :ct,
      }

      body = {}
      attributes.each do |key, value|
        new_key = map[key.to_sym]
        key = new_key if new_key
        body[key] = value
      end

      # Add transition
      body.merge!({:transitiontime => transition}) if transition

      uri = URI.parse("#{base_url}/state")
      http = Net::HTTP.new(uri.hostname)
      response = http.request_put(uri.path, MultiJson.dump(body))
      MultiJson.load(response.body)
    end

    # Refresh the state of the lamp
    def refresh
      json = MultiJson.load(Net::HTTP.get(URI.parse(base_url)))

      @state = json['state']
      @brightness = @state['bri']
      @hue = @state['hue']
      @saturation = @state['sat']
      @x, @y = @state['xy']
      @color_temperature = @state['ct']
      @alert = @state['alert'].to_sym
      @effect = @state['effect'].to_sym
      @color_mode = @state['colormode']
      @type = json['type']
      @name = json['name']
      @model = json['modelid']
      @software_version = json['swversion']
      @point_symbol = json['pointsymbol']
    end

  private

    def base_url
      bridge_ip = @client.base_station['internalipaddress']
      "http://#{bridge_ip}/api/#{@client.username}/lights/#{id}"
    end
  end
end
