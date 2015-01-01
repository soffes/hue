module Hue
  class Scene
    include Enumerable
    include TranslateKeys

    # Unique identification number.
    attr_reader :id

    # Bridge the scene is associated with
    attr_reader :bridge

    # A unique, editable name given to the scene.
    attr_accessor :name

    # Whether or not the scene is active on a group.
    attr_reader :active

    def initialize(client, bridge, id, data)
      @client = client
      @bridge = bridge
      @id = id

      unpack(data)
    end

    def lights
      @lights ||= begin
        @light_ids.map do |light_id|
          @client.light(light_id)
        end
      end
    end

    private

    SCENE_KEYS_MAP = {
      :name => :name,
      :light_ids => :lights,
      :active => :active,
    }

    def unpack(data)
      unpack_hash(data, SCENE_KEYS_MAP)
    end

    def base_url
      "http://#{@bridge.ip}/api/#{@client.username}/scenes/#{id}"
    end
  end
end
