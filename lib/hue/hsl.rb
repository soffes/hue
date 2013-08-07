module Hue
  class HSL
    def initialize(h, s, l)
      @hue = h.to_f
      @saturation = s.to_f
      @luminance = l.to_f
    end

    def to_hue
      h = (@hue / 360) * 65535
      s = @saturation * 255
      l = @luminance * 255
      {hue: h.to_i, saturation: s.to_i, luminance: l.to_i}
    end
  end
end
