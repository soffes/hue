require 'net/http'

module Hue
  class HTTP

    class TooManyRedirects < Error; end

    def initialize(uri_string)
      @uri = URI.parse(uri_string)
    end

    def fetch(limit = 10)
      raise TooManyRedirects if limit == 0

      http = Net::HTTP.new(uri.host, uri_port)
      http.use_ssl = use_ssl?
      response = http.get2(uri.path)

      case response
      when Net::HTTPSuccess then response.body
      when Net::HTTPRedirection
        @uri = URI.parse(response['location'])
        fetch(limit - 1)
      end
    end

  private

    attr_reader :uri

    def use_ssl?
      uri.scheme == 'https'
    end

    def uri_port
      use_ssl? ? 443 : 80
    end

  end
end
