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

    desc 'light ID STATE [COLOR]', 'Access a light'
    long_desc <<-LONGDESC
    Examples: \n
      hue all on \n
      hue all off \n
      hue all --hue 12345  \n
      hue all --brightness 25 \n
      hue all --hue 50000 --brightness 200 --saturation 240 \n
      hue all --alert lselect \n
    LONGDESC
    option :hue, :type => :numeric
    option :sat, :type => :numeric, :aliases => '--saturation'
    option :bri, :type => :numeric, :aliases => '--brightness'
    option :alert, :type => :string
    desc 'all STATE', 'Send commands to all lights'
    def all(state = 'on')
      body = options.dup
      body[:on] = state == 'on'
      client.lights.each do |light|
        puts light.set_state body
      end
    end

    desc 'light ID STATE [COLOR]', 'Access a light'
    long_desc <<-LONGDESC
    Examples: \n
      hue light 1 on --hue 12345  \n
      hue light 1 --brightness 25 \n
      hue light 1 --alert lselect \n
      hue light 1 off
    LONGDESC
    option :hue, :type => :numeric
    option :sat, :type => :numeric, :aliases => '--saturation'
    option :brightness, :type => :numeric, :aliases => '--brightness'
    option :alert, :type => :string
    def light(id, state = nil)
      light = client.light(id)
      puts light.name

      body = options.dup
      body[:on] = (state == 'on' || !(state == 'off'))
      puts light.set_state(body) if body.length > 0
    end

    desc 'groups', 'Find all light groups on your network'
    def groups
      client.groups.each do |group|
        puts group.id.to_s.ljust(6) + group.name
        group.lights.each do |light|
          puts " -> " + light.id.to_s.ljust(6) + light.name
        end
      end
    end

    desc 'group ID STATE [COLOR]', 'Update a group of lights'
    long_desc <<-LONGDESC
    Examples: \n
      hue groups 1 on --hue 12345
      hue groups 1 --brightness 25
      hue groups 1 --alert lselect
      hue groups 1 off
    LONGDESC
    option :hue, :type => :numeric
    option :sat, :type => :numeric, :aliases => '--saturation'
    option :brightness, :type => :numeric, :aliases => '--brightness'
    option :alert, :type => :string
    def group(id, state = nil)
      group = client.group(id)
      puts group.name

      body = options.dup
      body[:on] = (state == 'on' || !(state == 'off'))
      puts group.set_state(body) if body.length > 0
    end

  private

    def client
      @client ||= Hue::Client.new
    end
  end
end
