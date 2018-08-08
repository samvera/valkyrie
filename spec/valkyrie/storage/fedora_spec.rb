# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Fedora do
  before(:all) do
    # Start from a clean fedora
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(
      connection: ::Ldp::Client.new("http://localhost:8988/rest"),
      base_path: "test"
    ).persister.wipe!
  end

  let(:connection) { ::Ldp::Client.new("http://localhost:8988/rest") }
  let(:storage_adapter) { described_class.new(connection: connection, base_path: 'test') }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

  it_behaves_like "a Valkyrie::StorageAdapter"
end
