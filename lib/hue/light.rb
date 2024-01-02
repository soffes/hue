module Hue
  class Light
    include TranslateKeys
    include EditableState

    HUE_RANGE = 0..65535
    SATURATION_RANGE = 0..255
    BRIGHTNESS_RANGE = 0..255
    COLOR_TEMPERATURE_RANGE = 153..500

    # Unique identification number.
    attr_reader :id

    # Bridge the light is associated with
    attr_reader :bridge

    # A unique, editable name given to the light.
    attr_accessor :name

    # Hue of the light. This is a wrapping value between 0 and 65535.
    # Both 0 and 65535 are red, 25500 is green and 46920 is blue.
    attr_reader :hue

    # Saturation of the light. 255 is the most saturated (colored)
    # and 0 is the least saturated (white).
    attr_reader :saturation

    # Brightness of the light. This is a scale from the minimum
    # brightness the light is capable of, 0, to the maximum capable
    # brightness, 255. Note a brightness of 0 is not off.
    attr_reader :brightness

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
    attr_reader :color_temperature

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
    attr_reader :alert

    # The dynamic effect of the light, can either be `none` or
    # `colorloop`. If set to colorloop, the light will cycle through
    # all hues using the current brightness and saturation settings.
    attr_reader :effect

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
      response = http.request_put(uri.path, JSON.dump(body))
      response = JSON(response.body).first
      if response['success']
        @name = new_name
      # else
        # TODO: Error
      end
    end

    # Indicates if a light can be reached by the bridge. Currently
    # always returns true, functionality will be added in a future
    # patch.
    def reachable?
      @state['reachable']
    end

    # @param transition The duration of the transition from the light’s current
    #   state to the new state. This is given as a multiple of 100ms and
    #   defaults to 4 (400ms). For example, setting transistiontime:10 will
    #   make the transition last 1 second.
    def set_state(attributes, transition = nil)
      body = translate_keys(attributes, STATE_KEYS_MAP)

      # Add transition
      body.merge!({:transitiontime => transition}) if transition

      uri = URI.parse("#{base_url}/state")
      http = Net::HTTP.new(uri.host)
      response = http.request_put(uri.path, JSON.dump(body))
      JSON(response.body)
    end

    # Refresh the state of the lamp
    def refresh
      json = JSON(Net::HTTP.get(URI.parse(base_url)))
      unpack(json)
    end

    def rgb
      Color::HSL.new(self.hue.to_f / 182.04, self.saturation.to_f / 255.0 * 100.0, self.brightness.to_f / 255.0 * 100.0).to_rgb.html
    end

    def rgb=(hex)
      color = Color::RGB.from_html(hex)

      # Manual calcuation is necessary here because of an error in the Color library
      r = color.r
      g = color.g
      b = color.b
      max = [r, g, b].max
      min = [r, g, b].min
      delta = max - min
      v = max * 100

      if (max != 0.0)
        s = delta / max * 100
      else
        s = 0.0
      end

      if (s == 0.0)
        h = 0.0
      else
        if (r == max)
          h = (g - b) / delta
        elsif (g == max)
          h = 2 + (b - r) / delta
        elsif (b == max)
          h = 4 + (r - g) / delta
        end

        h *= 60.0

        if (h < 0)
          h += 360.0
        end
      end

      self.hue = (h * 182.04).round
      self.saturation = (s / 100.0 * 255.0).round
      self.brightness = (v / 100.0 * 255.0).round
    end


  private

    KEYS_MAP = {
      :state => :state,
      :type => :type,
      :name => :name,
      :model => :modelid,
      :software_version => :swversion,
      :point_symbol => :pointsymbol
    }

    STATE_KEYS_MAP = {
      :on => :on,
      :brightness => :bri,
      :hue => :hue,
      :saturation => :sat,
      :xy => :xy,
      :color_temperature => :ct,
      :alert => :alert,
      :effect => :effect,
      :color_mode => :colormode,
      :reachable => :reachable,
    }

    def unpack(hash)
      unpack_hash(hash, KEYS_MAP)
      unpack_hash(@state, STATE_KEYS_MAP)
      @x, @y = @state['xy']
    end

    def base_url
      "http://#{@bridge.ip}/api/#{@client.username}/lights/#{id}"
    end
  end
end
