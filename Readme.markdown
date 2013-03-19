# Hue

Work with Philips Hue light bulbs from Ruby.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'hue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hue

## Usage

``` ruby
> client = Hue::Client.new
> light = client.lights.first
> light.on = true
```

## Contributing

See the [contributing guide](Contributing.markdown).
