RSpec.describe Hue::Client do
  describe "#bridge" do
    before do
      stub_request(:get, "https://www.meethue.com/api/nupnp").
        to_return(:body => '[{"id":"ffa57b3b257200065704","internalipaddress":"192.168.0.1"},{"id":"63c2fc01391276a319f9","internalipaddress":"192.168.0.2"}]')

      stub_request(:get, %r{http://192.168.0.1/api/*}).
        to_return(:body => '[{"success":true}]')

      stub_request(:get, %r{http://192.168.0.2/api/*}).
        to_return(:body => '[{"success":true}]')
    end

    context "when bridge_id exists" do
      before do
        allow_any_instance_of(Hue::Client).to receive(:find_bridge_id).and_return('63c2fc01391276a319f9')
      end

      it 'return the bridge whose id is specified.' do
        client = Hue::Client.new
        expect(client.bridge.id).to eq('63c2fc01391276a319f9')
      end
    end

    context "when no bridge_id exists" do
      it 'return the first bridge.' do
        client = Hue::Client.new
        expect(client.bridge.id).to eq('ffa57b3b257200065704')
      end
    end
  end
end
