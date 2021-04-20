# frozen_string_literal: true
module FedoraHelper
  def fedora_adapter_config(base_path:, schema: nil, fedora_version: 4)
    port = 8988
    if fedora_version == 5
      port = 8998
    elsif fedora_version == 6
      port = ENV["FEDORA_6_PORT"] || 8978
    end
    connection_url = fedora_version == 6 ? "/fcrepo/rest" : "/rest"
    opts = {
      base_path: base_path,
      connection: ::Ldp::Client.new(faraday_client("http://#{fedora_auth}localhost:#{port}#{connection_url}")),
      fedora_version: fedora_version
    }
    opts[:schema] = schema if schema
    opts
  end

  def faraday_client(url)
    Faraday.new(url) do |f|
      f.request :multipart
      f.request :url_encoded
      f.basic_auth 'fedoraAdmin', 'fedoraAdmin'
      f.adapter Faraday.default_adapter
    end
  end

  def fedora_auth
    "fedoraAdmin:fedoraAdmin@"
  end

  def wipe_fedora!(base_path:, fedora_version: 4)
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(fedora_adapter_config(base_path: base_path, fedora_version: fedora_version)).persister.wipe!
  end
end

RSpec.configure do |config|
  config.before(:example, :wipe_fedora) do
    wipe_fedora!(base_path: "test_fed", fedora_version: 4)
    wipe_fedora!(base_path: "test_fed", fedora_version: 5)
    wipe_fedora!(base_path: "test_fed", fedora_version: 6)
  end
  config.include FedoraHelper
end
