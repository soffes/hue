require 'net/http'
require 'multi_json'

module Hue
  class Client
    attr_reader :username

    def initialize(username = '1234567890')
      unless USERNAME_RANGE.include?(username.length)
        raise InvalidUsername, "Usernames must be between #{USERNAME_RANGE.first} and #{USERNAME_RANGE.last}."
      end

      @username = username
      validate_user
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
        MultiJson.load(Net::HTTP.get(URI.parse('http://www.meethue.com/api/nupnp'))).each do |hash|
          bs << Bridge.new(self, hash)
        end
        bs
      end
    end

    def lights
      @lights ||= begin
        ls = []
        json = MultiJson.load(Net::HTTP.get(URI.parse("http://#{bridge.ip}/api/#{@username}")))
        json['lights'].each do |key, value|
          ls << Light.new(self, bridge, key, value)
        end
        ls
      end
    end

    def light(id)
      self.lights.select { |l| l.id == id }.first
    end

    def groups
      @groups ||= begin
        # Group 0 is not returned in API v1.0 requests
        gs = [Group.new(self, bridge, "0", {"action" => {}, "name" => "All"})]
        json = MultiJson.load(Net::HTTP.get(URI.parse("http://#{bridge.ip}/api/#{@username}/groups")))
        json.each do |key, value|
          gs << Group.new(self, bridge, key, value).refresh
        end
        gs
      end
    end

    def group(id = "0")
      self.groups.select { |g| g.id == id }.first
    end

  private

    def validate_user
      response = MultiJson.load(Net::HTTP.get(URI.parse("http://#{bridge.ip}/api/#{@username}")))

      if response.is_a? Array
        response = response.first
      end

      if error = response['error']
        parse_error(error)
      end
      response['success']
    end

    def register_user
      body = {
        devicetype: 'Ruby',
        username: @username
      }

      uri = URI.parse("http://#{bridge.ip}/api")
      http = Net::HTTP.new(uri.host)
      response = MultiJson.load(http.request_post(uri.path, MultiJson.dump(body)).body).first

      if error = response['error']
        parse_error(error)
      end
      response['success']
    end

    def parse_error(error)
      # Find error or return
      klass = Hue::ERROR_MAP[error['type']]
      klass = UnknownError unless klass

      # Raise error
      raise klass.new(error['description'])
    rescue  Hue::UnauthorizedUser
      register_user
    end
  end
end
