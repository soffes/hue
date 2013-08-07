module Hue
  class RGB

    attr_reader :red, :green, :blue

    def initialize(r, g, b)
      @red = r.to_f / 255
      @green = g.to_f / 255
      @blue = b.to_f / 255
      @max = [@red, @green, @blue].max
      @min = [@red, @green, @blue].min
    end
    
    def to_hsl
      l = self.luminance
      s = self.saturation
      h = self.hue
      HSL.new(h, s, l)
    end

    def to_hue
      to_hsl.to_hue
    end

    def to_hex
      "#{@red.to_s(16)}#{@green.to_s(16)}#{@blue.to_s(16)}"
    end

    def luminance
      @luminance ||= 0.5 * (@max + @min)
    end

    def saturation
      self.luminance unless @luminance
      if @max == @min
        @saturation ||= 0
      elsif @luminance <= 0.5
        @saturation ||= (@max - @min) / (2.0 * @luminance)
      else
        @saturation ||= (@max - @min) / (2.0 - 2.0 * @luminance)
      end
    end

    def hue
      if @saturation.zero?
        @hue ||= 0
      else
        case @max
        when red
          @hue ||= (60.0 * ((@green - @blue) / (@max - @min))) % 360.0
        when green
          @hue ||= 60.0 * ((@blue - @red) / (@max - @min)) + 120.0
        when blue
          @hue ||= 60.0 * ((@red - @green) / (@max - @min)) + 240.0
        end
      end
    end
  end
end
