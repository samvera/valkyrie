# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(connection: ::Ldp::Client.new("http://localhost:8988/rest"), base_path: "test_fed").persister.wipe!
  end
end
