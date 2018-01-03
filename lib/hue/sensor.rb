module Hue
  class Sensor
    include TranslateKeys

    # Unique identification number.
    attr_reader :id

    # Bridge the sensor is associated with
    attr_reader :bridge

    # A unique, editable name given to the sensor.
    attr_accessor :name

    # A fixed name describing the type of sensor.
    attr_reader :type

    # The hardware model of the sensor.
    attr_reader :model

    # The unique identifier of the sensor.
    attr_reader :uuid

    # An identifier for the software version running on the sensor.
    attr_reader :software_version

    attr_reader :button_event

    attr_reader :last_updated

    def initialize(client, bridge, id, hash)
      @client = client
      @bridge = bridge
      @id = id
      unpack(hash)
    end

    def name=(new_name)
      unless (1..32).include?(new_name.length)
        raise InvalidValueForParameter, 'name must be between 1 and 32 characters.'
      end

      body = {
        :name => new_name
      }

      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.host)
      response = http.request_put(uri.path, JSON.dump(body))
      response = JSON(response.body).first
      if response['success']
        @name = new_name
      # else
        # TODO: Error
      end
    end

    # Indicates if a senosr can be reached by the bridge. Currently
    # always returns true, functionality will be added in a future
    # patch.
    def reachable?
      @state['reachable']
    end

    # Refresh the state of the refresh
    def refresh
      json = JSON(Net::HTTP.get(URI.parse(base_url)))
      unpack(json)
    end

  private

    KEYS_MAP = {
      :state => :state,
      :config => :config,
      :name => :name,
      :type => :type,
      :model => :modelid,
      :manufacturer => :manufacturername,
      :software_version => :swversion,
      :uuid => :uniqueid,
    }

    STATE_KEYS_MAP = {
      :daylight => :daylight,
      :last_updated => :lastupdated,
      :button_event => :buttonevent,
    }

    def unpack(hash)
      unpack_hash(hash, KEYS_MAP)
      unpack_hash(@state, STATE_KEYS_MAP)
    end

    def base_url
      "http://#{@bridge.ip}/api/#{@client.username}/sensors/#{id}"
    end
  end
end
