require 'thor'

module Hue
  class Cli < Thor
    desc 'lights', 'Find all of the lights on your network'
    def lights
      client.lights.each do |light|
        puts light.id.to_s.ljust(6) + light.name
      end
    end

    desc 'all STATE', 'Send commands to all lights'
    def all(state)
      on = state == 'on'
      client.lights.each do |light|
        light.on = on
      end
    end

    desc 'light ID STATE', 'Access a light'
    option :hue, :type => :numeric
    option :saturation, :type => :numeric
    option :brightness, :type => :numeric
    def light(id, state = nil)
      light = client.light(id)
      puts light.name

      body = options.dup
      body[:on] = state unless state.nil?
      light.set_state(body) if body.length > 0
    end

  private

    def client
      @client ||= Hue::Client.new
    end
  end
end
