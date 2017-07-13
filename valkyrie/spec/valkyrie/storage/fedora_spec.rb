# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
require 'active_fedora/cleaner'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Fedora do
  before(:all) do
    # Start from a clean fedora
    ActiveFedora::Cleaner.clean!
  end
  it_behaves_like "a Valkyrie::StorageAdapter"
  let(:storage_adapter) { described_class.new(connection: ActiveFedora.fedora.connection) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
end
