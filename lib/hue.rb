require 'hue/version'
require 'hue/client'
require 'hue/light'

module Hue
  class Error < Exception; end
  class NoBaseStationFound < Error; end
  class ButtonNotPressed < Error; end
end
