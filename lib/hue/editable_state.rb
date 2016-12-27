module Hue
  module EditableState
    def on?
      @state['on']
    end

    def on!
      self.on = true
    end

    def off!
      self.on = false
    end

    # Turn the light on if it's off and vice versa
    def toggle!
      if @on
        self.off!
      else
        self.on!
      end
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
  end
end
