require 'net/http'
require 'json'

module Hue
  class Client
    attr_reader :username

    def initialize(username = '1234567890')
      unless USERNAME_RANGE.include?(username.length)
        raise InvalidUsername, "Usernames must be between #{USERNAME_RANGE.first} and #{USERNAME_RANGE.last}."
      end

      @username = username

      begin
        validate_user
      rescue Hue::UnauthorizedUser
        register_user
      end
    end

    def bridge
      # Pick the first one for now. In theory, they should all do the same thing.
      bridge = bridges.first
      raise NoBridgeFound unless bridge
      bridge
    end

    def bridges
      @bridges ||= begin
        bs = []
        JSON(Net::HTTP.get(URI.parse('https://www.meethue.com/api/nupnp'))).each do |hash|
          bs << Bridge.new(self, hash)
        end
        bs
      end
    end

    def lights
      bridge.lights
    end

    def add_lights
      bridge.add_lights
    end

    def light(id)
      id = id.to_s
      lights.select { |l| l.id == id }.first
    end

    def groups
      bridge.groups
    end

    def group(id)
      id = id.to_s
      groups.select { |l| l.id == id }.first
    end


  private

  def validate_user
    response = JSON(Net::HTTP.get(URI.parse("http://#{bridge.ip}/api/#{@username}")))

    if response.is_a? Array
      response = response.first
    end

    if error = response['error']
      raise get_error(error)
    end

    response['success']
  end

  def register_user
    body = JSON.dump({
      devicetype: 'Ruby',
      username: @username
    })

    uri = URI.parse("http://#{bridge.ip}/api")
    http = Net::HTTP.new(uri.host)
    response = JSON(http.request_post(uri.path, body).body).first

    if error = response['error']
      raise get_error(error)
    end

    response['success']
  end

  def get_error(error)
    # Find error class and return instance
    klass = Hue::ERROR_MAP[error['type']] || UnknownError unless klass
    klass.new(error['description'])
  end

  end
end
