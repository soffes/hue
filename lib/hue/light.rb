module Hue
  class Light
    attr_reader :id
    attr_accessor :name
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

    def name=(new_name)
      unless 1..32.include?(new_name.length)
        raise InvalidValueForParameter, 'name must be between 1 and 32 characters.'
      end

      body = {
        :name => new_name
      }

      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.hostname)
      response = http.request_put(uri.path, MultiJson.dump(body))
      response = MultiJson.load(response.body).first
      if response['success']
        @name = new_name
      # else
        # TODO: Error
      end
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
          :hue => hue,
          :sat => saturation,
          :bri => brightness
        })
      end

      uri = URI.parse("#{base_url}/state")
      http = Net::HTTP.new(uri.hostname)
      response = http.request_put(uri.path, MultiJson.dump(body))
      MultiJson.load(response.body)
    end

  private

    def base_url
      bridge_ip = @client.base_station['internalipaddress']
      "http://#{bridge_ip}/api/#{@client.username}/lights/#{self.id}"
    end

    def refresh
      json = MultiJson.load(Net::HTTP.get(URI.parse(base_url)))

      @state = json['state']
      @type = json['type']
      @name = json['name']
      @model = json['modelid']
      @software_version = json['swversion']
      @point_symbol = json['pointsymbol']
    end
  end
end
