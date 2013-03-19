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

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
