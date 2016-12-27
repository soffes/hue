RSpec.describe Hue::Light do
  %w{on hue saturation brightness color_temperature alert effect}.each do |attribute|
    before do
      stub_request(:get, "https://www.meethue.com/api/nupnp").
        to_return(:body => '[{"internalipaddress":"localhost"}]')

      stub_request(:get, %r{http://localhost/api/*}).
        to_return(:body => '[{"success":true}]')

      stub_request(:put, %r{http://localhost/api*}).
        to_return(:body => '[{}]')

      @client = Hue::Client.new
    end

    describe "##{attribute}=" do
      it "PUTs the new attribute value" do
        light = Hue::Light.new(@client, @client.bridge, 0, {"state" => {}})

        light.send("#{attribute}=", 24)
        expect(a_request(:put, %r{http://localhost/api/.*/lights/0})).to have_been_made
      end
    end
  end

  describe "#off?" do
    it "should return the opposite of state['on']" do
      state = {'on' => true}
      light = Hue::Light.new(@client, @client.bridge, 0, "state" => state)
      expect(light.off?).to be false

      state = {}
      light = Hue::Light.new(@client, @client.bridge, 0, "state" => state)
      expect(light.off?).to be true

      state = {'off' => false}
      light = Hue::Light.new(@client, @client.bridge, 0, "state" => state)
      expect(light.off?).to be true
    end
  end
end
