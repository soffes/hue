module Hue
  class Light
    include Hue::Controllable

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

    def on?
      @state['on']
    end

    # Indicates if a light can be reached by the bridge. Currently
    # always returns true, functionality will be added in a future
    # patch.
    def reachable?
      @state['reachable']
    end

  private

    STATE_PATH = "state"

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
      :reachable => :reachable
    }

    def unpack(hash)
      super
      @x, @y = @state['xy']
    end

    def base_url
      "http://#{@bridge.ip}/api/#{@client.username}/lights/#{id}"
    end
  end
end
