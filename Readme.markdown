# Hue

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

## Usage

The first time you use it, it will automatically create a user for you. Doing this requires you to have pushed the button on your bridge in the last 30 seconds. If you haven't it will throw an exception and let you know you need to push the button. Simply press the button and run the command again.

From CLI:

``` shell
$ hue all on
$ hue all off
```

From Ruby:

``` ruby
> client = Hue::Client.new
> light = client.lights.first
> light.on = true
```

## Contributing

See the [contributing guide](Contributing.markdown).
