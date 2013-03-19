module Hue
  class Light
    attr_reader :id
    attr_reader :name
    attr_reader :state
    attr_reader :type
    attr_reader :model
    attr_reader :software_version
    attr_reader :point_symbol

    def initialize(client, id, name)
      @client = client
      @id = id
      @name = name
      refresh
    end

    def on?
      @state['on']
    end

    def on=(new_state)
      self.set_state(new_state)
    end

    def hsb
      @state.select { |k, v| %w{sat bri hue}.include?(k) }
    end

    def set_state(on, hue = nil, saturation = nil, brightness = nil)
      body = {
        on: on
      }

      if on
        body.merge!({
          hue: hue,
          sat: saturation,
          bri: brightness
        })
      end

      bridge_ip = @client.base_station['internalipaddress']
      uri = URI.parse("http://#{bridge_ip}/api/#{@client.username}/lights/#{self.id}/state")

      http = Net::HTTP.new(uri.hostname)
      response = http.request_put(uri.path, MultiJson.dump(body))
      MultiJson.load(response.body)
    end

  private

    def refresh
      bridge_ip = @client.base_station['internalipaddress']
      uri = URI.parse("http://#{bridge_ip}/api/#{@client.username}/lights/#{self.id}")
      json = MultiJson.load(Net::HTTP.get(uri))

      @state = json['state']
      @type = json['type']
      @name = json['name']
      @model = json['modelid']
      @software_version = json['swversion']
      @point_symbol = json['pointsymbol']
    end
  end
end
