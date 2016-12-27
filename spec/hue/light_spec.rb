RSpec.describe Hue::Light do
  %w{on hue saturation brightness color_temperature alert effect}.each do |attribute|
    before do
      stub_request(:get, "https://www.meethue.com/api/nupnp").
        to_return(:body => '[{"internalipaddress":"localhost"}]')

      stub_request(:get, %r{http://localhost/api/*}).
        to_return(:body => '[{"success":true}]')

      stub_request(:put, %r{http://localhost/api*}).
        to_return(:body => '[{}]')
    end

    describe "##{attribute}=" do
      it "PUTs the new attribute value" do
        client = Hue::Client.new
        light = Hue::Light.new(client, client.bridge, 0, {"state" => {}})

        light.send("#{attribute}=", 24)
        expect(a_request(:put, %r{http://localhost/api/.*/lights/0})).to have_been_made
      end
    end
  end

  describe "#toggle" do
    it "switches a powered light off" do
      client = Hue::Client.new
      light = Hue::Light.new(client, client.bridge, 0, {"state" => {}})

      light.on!

      expect(light).to receive(:off!)

      light.toggle!
    end

    it "switches an unpowered light on" do
      client = Hue::Client.new
      light = Hue::Light.new(client, client.bridge, 0, {"state" => {}})

      light.off!

      expect(light).to receive(:on!)

      light.toggle!
    end
  end
end
