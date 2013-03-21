# Hue

Work with Philips Hue light bulbs from Ruby.

[![Code Climate](https://codeclimate.com/github/soffes/hue.png)](https://codeclimate.com/github/soffes/hue) [![Dependency Status](https://gemnasium.com/soffes/hue.png)](https://gemnasium.com/soffes/hue) [![Gem Version](https://badge.fury.io/rb/hue.png)](http://badge.fury.io/rb/hue)

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

From CLI:

``` shell
$ hue all on
$ hue all off
$ hue light 2 on
$ hue light 2 --brightness 20
```

From Ruby:

``` ruby
> client = Hue::Client.new
> light = client.lights.first
> light.on = true
> light.hue = 46920
> light.color_temperature = 100
> light.set_state({:color_temperature => 400, :transition => 100})
```

## Contributing

See the [contributing guide](Contributing.markdown).
