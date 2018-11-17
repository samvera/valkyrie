# frozen_string_literal: true
module FedoraHelper
  def fedora_adapter_config(base_path:, schema: nil)
    opts = {
      base_path: base_path,
      connection: ::Ldp::Client.new("http://localhost:8988/rest"),
      fedora_version: ENV["FEDORA5_COMPAT"].present? ? 5 : 4
    }
    opts[:schema] = schema if schema
    opts
  end

  def wipe_fedora!(base_path:)
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(fedora_adapter_config(base_path: base_path)).persister.wipe!
  end
end

RSpec.configure do |config|
  config.before do
    wipe_fedora!(base_path: "test_fed")
  end
  config.include FedoraHelper
end
