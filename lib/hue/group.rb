module Hue
  class Group
    include Enumerable
    include TranslateKeys
    include EditableState

    # Unique identification number.
    attr_reader :id

    # Bridge the group is associated with
    attr_reader :bridge

    # A unique, editable name given to the group.
    attr_reader :name

    # Hue of the group. This is a wrapping value between 0 and 65535.
    # Both 0 and 65535 are red, 25500 is green and 46920 is blue.
    attr_accessor :hue

    # Saturation of the group. 254 is the most saturated (colored)
    # and 0 is the least saturated (white).
    attr_accessor :saturation

    # Brightness of the group. This is a scale from the minimum
    # brightness the group is capable of, 0, to the maximum capable
    # brightness, 254. Note a brightness of 0 is not off.
    attr_accessor :brightness

    # The x coordinate of a color in CIE color space. Between 0 and 1.
    #
    # @see http://developers.meethue.com/coreconcepts.html#color_gets_more_complicated
    attr_reader :x

    # The y coordinate of a color in CIE color space. Between 0 and 1.
    #
    # @see http://developers.meethue.com/coreconcepts.html#color_gets_more_complicated
    attr_reader :y

    # The Mired Color temperature of the light. 2012 connected lights
    # are capable of 153 (6500K) to 500 (2000K).
    #
    # @see http://en.wikipedia.org/wiki/Mired
    attr_accessor :color_temperature

    # A fixed name describing the type of group.
    attr_reader :type

    def initialize(client, bridge, id = nil, data = {})
      @client = client
      @bridge = bridge
      @id = id

      unpack(data)
    end

    def each(&block)
      lights.each(&block)
    end

    def lights
      @lights ||= @light_ids.map do |light_id|
        @client.light(light_id)
      end
    end

    def name=(name)
      resp = set_group_state({name: name})
      @name = new? ? name : resp[0]["success"]["/groups/#{id}/name"]
    end

    def lights=(light_ids)
      light_ids.map! do |light_id|
        light_id.is_a?(Light) ? light_id.id : light_id.to_s
      end

      @light_ids = light_ids.uniq
      @lights = nil # resets the memoization

      set_group_state({lights: @light_ids})
    end

    def scene=(scene)
      scene_id = scene.is_a?(Scene) ? scene.id : scene
      set_group_state({scene: scene_id})
    end

    def <<(light_id)
      @light_ids << light_id
      set_group_state({lights: @light_ids})
    end
    alias_method :add_light, :<<

    def set_group_state(attributes)
      return if new?
      body = translate_keys(attributes, GROUP_KEYS_MAP)

      uri = URI.parse(base_url)
      http = HttpClient.create(uri)
      response = http.request_put(uri.path, JSON.dump(body))
      JSON(response.body)
    end

    def set_state(attributes)
      return if new?
      body = translate_keys(attributes, STATE_KEYS_MAP)

      uri = URI.parse("#{base_url}/action")
      http = HttpClient.create(uri)
      response = http.request_put(uri.path, JSON.dump(body))
      JSON(response.body)
    end

    def refresh
      uri = URI.parse(base_url)
      http = HttpClient.create(uri)
      json = JSON(http.get(uri.path).body)
      unpack(json)
      @lights = nil
    end

    def create!
      body = {
        name: @name,
        lights: @light_ids
      }

      uri = URI.parse("https://#{@bridge.ip}/api/#{@client.username}/groups")
      http = HttpClient.create(uri)
      response = http.request_post(uri.path, JSON.dump(body))
      json = JSON(response.body)

      @id = json[0]["success"]["id"]
    end

    def destroy!
      uri = URI.parse(base_url)
      http = HttpClient.create(uri)
      response = http.delete(uri.path)
      json = JSON(response.body)
      @id = nil if json[0]["success"]
    end

    def new?
      @id.nil?
    end

    private

    GROUP_KEYS_MAP = {
      name: :name,
      light_ids: :lights,
      type: :type,
      state: :action
    }

    STATE_KEYS_MAP = {
      on: :on,
      brightness: :bri,
      hue: :hue,
      saturation: :sat,
      xy: :xy,
      color_temperature: :ct,
      alert: :alert,
      effect: :effect,
      color_mode: :colormode
    }

    def unpack(data)
      unpack_hash(data, GROUP_KEYS_MAP)

      unless new?
        unpack_hash(@state, STATE_KEYS_MAP)
        @x, @y = @state["xy"]
      end
    end

    def base_url
      "https://#{@bridge.ip}/api/#{@client.username}/groups/#{id}"
    end
  end
end
