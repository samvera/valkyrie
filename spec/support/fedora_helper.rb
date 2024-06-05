# frozen_string_literal: true
require 'faraday'
require 'faraday/multipart'
module FedoraHelper
  def fedora_adapter_config(base_path:, schema: nil, fedora_version: 4, fedora_pairtree_count: 0, # rubocop:disable Metrics/MethodLength
                            fedora_pairtree_length: 0)
    port = 8988
    if fedora_version == 5
      port = 8998
    elsif fedora_version >= 6
      port = ENV["FEDORA_6_PORT"] || 8978
    end
    connection_url = fedora_version >= 6 || (fedora_version == 5 && !ENV["CI"]) ? "/fcrepo/rest" : "/rest"
    opts = {
      base_path: base_path,
      connection: ::Ldp::Client.new(faraday_client("http://#{fedora_auth}localhost:#{port}#{connection_url}")),
      fedora_version: fedora_version
    }
    opts[:schema] = schema if schema
    opts[:fedora_pairtree_count] = fedora_pairtree_count
    opts[:fedora_pairtree_length] = fedora_pairtree_length
    opts
  end

  def faraday_client(url)
    Faraday.new(url) do |f|
      f.request :multipart
      f.request :url_encoded
      if f.respond_to?(:basic_auth)
        f.basic_auth 'fedoraAdmin', 'fedoraAdmin'
      else
        f.request(:authorization, :basic, 'fedoraAdmin', 'fedoraAdmin')
      end
      f.adapter Faraday.default_adapter
    end
  end

  def fedora_auth
    "fedoraAdmin:fedoraAdmin@"
  end

  def wipe_fedora!(base_path:, fedora_version: 4)
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(**fedora_adapter_config(base_path: base_path, fedora_version: fedora_version)).persister.wipe!
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
