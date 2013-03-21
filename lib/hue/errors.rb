module Hue
  class Error < StandardError; end

  class UnauthorizedUser < Error; end
  class InvalidJSON < Error; end
  class ResourceNotAvailable < Error; end
  class MethodNotAvailable < Error; end
  class MissingBody < Error; end
  class ParameterNotAvailable < Error; end
  class InvalidValueForParameter < Error; end
  class ParameterNotModifiable < Error; end
  class InternalError < Error; end
  class LinkButtonNotPressed < Error; end
  class ParameterNotModifiableWhileOff < ParameterNotModifiable; end
  class TooManyGroups < Error; end
  class GroupTooFull < Error; end

  class InvalidUsername < Error; end
  class UnknownError < Error; end
  class NoBridgeFound < Error; end

  # Status code to exception map
  ERROR_MAP = {
      1 => Hue::UnauthorizedUser,
      2 => Hue::InvalidJSON,
      3 => Hue::ResourceNotAvailable,
      4 => Hue::MethodNotAvailable,
      5 => Hue::MissingBody,
      6 => Hue::ParameterNotAvailable,
      7 => Hue::InvalidValueForParameter,
      8 => Hue::ParameterNotModifiable,
    901 => Hue::InternalError,
    101 => Hue::LinkButtonNotPressed,
    201 => Hue::ParameterNotModifiableWhileOff,
    301 => Hue::TooManyGroups,
    302 => Hue::GroupTooFull
  }
end
