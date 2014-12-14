module Hue
  class Color
    class HexRGB < RGB
      def initialize(hex)
        hex = hex.scan(/../).map { |e| e.to_i(16) }
        super(hex[0], hex[1], hex[2])
      end
    end
  end
end
