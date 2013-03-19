require 'net/http'
require 'multi_json'

module Hue
  class Client
    attr_reader :username

    def initialize(username = 'huerubygem')
      @username = username
      validate_user
    end

    def base_station
      # Pick the first one for now. In theory, they should all do the same thing.
      base_station = base_stations.first
      raise NoBaseStationFound unless base_station
      base_station
    end

    def base_stations
      @base_stations ||= MultiJson.load(Net::HTTP.get(URI.parse('http://www.meethue.com/api/nupnp')))
    end

    def lights
      @lights ||= begin
        ls = []
        json = MultiJson.load(Net::HTTP.get(URI.parse("http://#{bridge_ip}/api/#{@username}/lights")))
        json.each do |key, value|
          ls << Light.new(self, key, value['name'])
        end
        ls
      end
    end

  private

    def validate_user
      response = MultiJson.load(Net::HTTP.get(URI.parse("http://#{bridge_ip}/api/#{@username}")))
      if error = response['error']
        register_user and return  if error['type'] == 1
        raise Error, error['description']
      end
      response['success']
    end

    def register_user
      body = {
        devicetype: 'test user',
        username: @usernamename
      }
      response = MultiJson.load(Net::HTTP.post(URI.parse("http://#{bridge_ip}/api"), MultiJson.dump(body))).first
      if error = response['error']
        raise ButtonNotPressed and return if error['type'] == 101
        raise Error, error['description']
      end
      response['success']
    end

    def bridge_ip
      base_station['internalipaddress']
    end
  end
end
