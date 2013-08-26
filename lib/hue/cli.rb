require 'thor'

module Hue
  class Cli < Thor
    desc 'lights', 'Find all of the lights on your network'
    def lights
      client.lights.each do |light|
        puts light.id.to_s.ljust(6) + light.name
      end
    end

    desc 'add LIGHTS', 'Search for new lights'
    def add(thing)
      case thing
      when 'lights'
        client.add_lights
      end
    end

    desc 'all STATE', 'Send commands to all lights'
    def all(state)
      on = state == 'on'
      client.lights.each do |light|
        light.on = on
      end
    end

    desc 'light ID STATE [COLOR]', 'Access a light'
    long_desc <<-LONGDESC
    Examples: \n
      hue light 1 on --hue 12345  \n
      hue light 1 --bri 25 \n
      hue light 1 --alert lselect \n
      hue light 1 off
    LONGDESC
    option :hue, :type => :numeric
    option :sat, :type => :numeric
    option :bri, :type => :numeric
    option :alert, :type => :string
    def light(id, state = nil)
      light = client.light(id)
      puts light.name

      body = options.dup
      body[:on] = (state == 'on' || !(state == 'off'))
      puts light.set_state(body) if body.length > 0
    end

  private

    def client
      @client ||= Hue::Client.new
    end
  end
end
