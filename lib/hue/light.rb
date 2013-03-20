module Hue
  class Light
    # Unique identification number.
    attr_reader :id

    # A unique, editable name given to the light.
    attr_accessor :name

    # Brightness of the light. This is a scale from the minimum
    # brightness the light is capable of, 0, to the maximum capable
    # brightness, 255. Note a brightness of 0 is not off.
    attr_accessor :brightness

    # Hue of the light. This is a wrapping value between 0 and 65535.
    # Both 0 and 65535 are red, 25500 is green and 46920 is blue.
    attr_accessor :hue

    # Saturation of the light. 255 is the most saturated (colored)
    # and 0 is the least saturated (white).
    attr_accessor :saturation

    # The x and y coordinates of a color in CIE color space.
    # The first entry is the x coordinate and the second entry is the
    # y coordinate. Both x and y are between 0 and 1.
    #
    # @see http://developers.meethue.com/coreconcepts.html#color_gets_more_complicated
    attr_accessor :xy

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
    attr_reader :colormode

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

    def on=(new_state)
      self.set_state(new_state)
    end

    def hsb
      @state.select { |k, v| %w{sat bri hue}.include?(k) }
    end

    # Indicates if a light can be reached by the bridge. Currently
    # always returns true, functionality will be added in a future
    # patch.
    def reachable?
      @state['reachable']
    end

    def set_state(on, hue = nil, saturation = nil, brightness = nil)
      body = {
        on: on
      }

      if on
        body.merge!({
          :hue => hue,
          :sat => saturation,
          :bri => brightness
        })
      end

      uri = URI.parse("#{base_url}/state")
      http = Net::HTTP.new(uri.hostname)
      response = http.request_put(uri.path, MultiJson.dump(body))
      MultiJson.load(response.body)
    end

  private

    def base_url
      bridge_ip = @client.base_station['internalipaddress']
      "http://#{bridge_ip}/api/#{@client.username}/lights/#{self.id}"
    end

    def refresh
      json = MultiJson.load(Net::HTTP.get(URI.parse(base_url)))

      @state = json['state']
      @type = json['type']
      @name = json['name']
      @model = json['modelid']
      @software_version = json['swversion']
      @point_symbol = json['pointsymbol']
    end
  end
end
