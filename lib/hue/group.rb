module Hue
  class Group
    include Hue::Controllable

  private

    STATE_PATH = "action"

    KEYS_MAP = {
      :state => :action,
      :lights => :lights,
      :name => :name
    }

    STATE_KEYS_MAP = {
      :on => :on,
      :brightness => :bri,
      :hue => :hue,
      :saturation => :sat,
      :xy => :xy,
      :color_temperature => :ct,
      :alert => :alert,
      :effect => :effect
    }

    def base_url
      "http://#{@bridge.ip}/api/#{@client.username}/groups/#{id}"
    end
  end
end
