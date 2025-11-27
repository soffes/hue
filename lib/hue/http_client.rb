# Helper module for creating HTTPS connections to the Hue Bridge.
# The Hue Bridge uses a self-signed certificate, so we disable verification.
module Hue
  module HttpClient
    def self.create(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end
  end
end
