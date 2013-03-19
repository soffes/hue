# Hue

Work with Philips Hue light bulbs from Ruby.

## Installation

This gem is currently unreleased. For now, simply clone the repository.

## Usage

``` shell
$ git clone https://github.com/soffes/hue.git
$ irb -Ihue/lib -rhue
```

``` ruby
> client = Hue::Client.new
> light = client.lights.first
> light.on = true
```

## Contributing

See the [contributing guide](Contributing.markdown).
