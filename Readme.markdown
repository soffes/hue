# Hue

[![Gem Version](https://img.shields.io/gem/v/hue.svg)](http://rubygems.org/gems/hue)
[![Build Status](https://img.shields.io/travis/soffes/hue/master.svg)](https://travis-ci.org/soffes/hue)

Work with Philips Hue light bulbs from Ruby.


## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'hue'
```

And then execute:

``` shell
$ bundle
```

Or install it yourself as:

``` shell
$ gem install hue
```

## Usage

The first time you use it, it will automatically create a user for you. Doing this requires you to have pushed the button on your bridge in the last 30 seconds. If you haven't it will throw an exception and let you know you need to push the button. Simply press the button and run the command again.

### CLI

``` shell
$ hue all on
$ hue all off
$ hue all --hue 65280 --brightness 20
$ hue light 2 on
$ hue light 2 --brightness 20
```

### Ruby

``` ruby
client = Hue::Client.new
```

#### Lights

``` ruby
light = client.lights.first
light.on!
light.hue = 46920
light.color_temperature = 100
transition_time = 10*5 # Hue transition times are in 1/10 of a second.
light.set_state({:color_temperature => 400}, transition_time)
```

#### Groups

``` ruby
# Fetching
group = client.groups.first
group = client.group(1)

# Accessing group lights
group.lights.first.on!
group.lights.each { |light| light.hue = rand(Hue::Light::HUE_RANGE) }

# Creating groups
group = client.group # Don't specify an ID
group.name = "My Group"
group.lights = [3, 4] # Can specify lights by ID
group.lights = client.lights.first(2) # Or by Light objects
group.new? # => true
group.create! # Once the group is created, you can continue to customize it
group.new? # => false

# Destroying groups
client.groups.last.destroy!
```

## Contributing

See the [contributing guide](Contributing.markdown).
