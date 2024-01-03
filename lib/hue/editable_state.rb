require 'color_conversion'

module Hue
  module EditableState
    HUE_RANGE = 0..65535
    SATURATION_RANGE = 0..254
    BRIGHTNESS_RANGE = 0..254

    def on?
      @state['on']
    end

    def on!
      self.on = true
    end

    def off!
      self.on = false
    end

    %w{on hue saturation brightness color_temperature alert effect}.each do |key|
      define_method "#{key}=".to_sym do |value|
        set_state({key.to_sym => value})
        instance_variable_set("@#{key}".to_sym, value)
      end
    end

    def set_xy(x, y)
      set_state({:xy => [x, y]})
      @x, @y = x, y
    end

    def hex
      ColorConversion::Color.new(h: hue, s: saturation, b: brightness).hex
    end

    def hex=(hex)
      hex = "##{hex}" unless hex.start_with?('#')
      hsb = ColorConversion::Color.new(hex).hsb

      # Map values from standard HSB to what Hue wants and update state
      state = {
        hue: ((hsb[:h].to_f / 360.0) * HUE_RANGE.last.to_f).to_i,
        saturation: ((hsb[:s].to_f / 100.0) * SATURATION_RANGE.last.to_f).to_i,
        brightness: ((hsb[:b].to_f / 100.0) * BRIGHTNESS_RANGE.last.to_f).to_i
      }

      set_state(state)

      @hue = state[:hue]
      @saturation = state[:saturation]
      @brightness = state[:brightness]
    end
  end
end
