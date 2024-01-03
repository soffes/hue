require 'net/http'
require 'json'
require 'resolv'

module Hue
  class Client
    attr_reader :username

    def initialize(username = nil, use_mdns: true)
      @bridge_id = nil
      @username = username || find_username
      @use_mdns = use_mdns

      if @username
        begin
          validate_user
        rescue Hue::UnauthorizedUser
          register_user
        end
      else
        register_user
      end
    end

    def bridge
      @bridge_id = find_bridge_id unless @bridge_id
      if @bridge_id
        bridge = bridges.select { |b| b.id == @bridge_id }.first
      else
        bridge = bridges.first
      end
      raise NoBridgeFound unless bridge
      bridge
    end

    def bridges
      @bridges ||= begin
        bs = []
        discovery_mdns(bs) if @use_mdns
        discovery_meethue(bs) if bs.empty?
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

    def group(id = nil)
      return Group.new(self, bridge) if id.nil?

      id = id.to_s
      groups.select { |g| g.id == id }.first
    end

    def scenes
      bridge.scenes
    end

    def scene(id)
      id = id.to_s
      scenes.select { |s| s.id == id }.first
    end

    private

    def find_username
      return ENV['HUE_USERNAME'] if ENV['HUE_USERNAME']

      json = JSON(File.read(File.expand_path('~/.hue')))
      json['username']
    rescue
      return nil
    end

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
        devicetype: 'Ruby'
      })

      uri = URI.parse("http://#{bridge.ip}/api")
      http = Net::HTTP.new(uri.host)
      response = JSON(http.request_post(uri.path, body).body).first

      if error = response['error']
        raise get_error(error)
      end

      if @username = response['success']['username']
        File.write(File.expand_path('~/.hue'), JSON.dump({username: @username}))
      end
    end

    def find_bridge_id
      return ENV['HUE_BRIDGE_ID'] if ENV['HUE_BRIDGE_ID']

      json = JSON(File.read(File.expand_path('~/.hue')))
      json['bridge_id']
    rescue
      return nil
    end

    def discovery_mdns(bs)
      resolver = Resolv::MDNS.new
      resolver.timeouts = 10

      resolver.each_resource("_hue._tcp.local", Resolv::DNS::Resource::IN::PTR) do |bridge_ptr|
        bridge_target = resolver.getresource(bridge_ptr.name, Resolv::DNS::Resource::IN::SRV).target

        bridge_hash = {
        'id' => resolver.getresource(bridge_ptr.name, Resolv::DNS::Resource::IN::TXT).strings[0].split('=')[1],
        'internalipaddress' => resolver.getresource(bridge_target, Resolv::DNS::Resource::IN::A).address
        }

        bs << Bridge.new(self, bridge_hash)
      end
    end

    def discovery_meethue(bs)
      uri = URI('https://discovery.meethue.com/')
      response = Net::HTTP.get(uri)
      
      JSON(response).each do |hash|
        bs << Bridge.new(self, hash)
      end
    end

    def get_error(error)
      # Find error class and return instance
      klass = Hue::ERROR_MAP[error['type']] || UnknownError unless klass
      klass.new(error['description'])
    end
  end
end
