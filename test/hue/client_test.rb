require "test_helper"

class ClientTest < Minitest::Test
  def before_setup
    super

    stub_request(:get, "https://discovery.meethue.com/")
      .to_return(body: '[{"id":"ffa57b3b257200065704","internalipaddress":"192.168.0.1"},{"id":"63c2fc01391276a319f9","internalipaddress":"192.168.0.2"}]')

    stub_request(:post, "http://192.168.0.1/api").to_return(body: '[{"success":{"username":"ruby"}}]')
    stub_request(:get, %r{http://192.168.0.1/api/*}).to_return(body: '[{"success":true}]')
    stub_request(:get, %r{http://192.168.0.2/api/*}).to_return(body: '[{"success":true}]')
  end

  def test_with_bridge_id
    client = Hue::Client.new(use_mdns: false)
    client.stub :find_bridge_id, "63c2fc01391276a319f9" do
      assert_equal "63c2fc01391276a319f9", client.bridge.id
    end
  end

  def test_without_bridge_id
    client = Hue::Client.new(use_mdns: false)
    assert_equal "ffa57b3b257200065704", client.bridge.id
  end
end
