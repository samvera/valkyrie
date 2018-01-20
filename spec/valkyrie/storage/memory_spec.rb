# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Memory do
  it_behaves_like "a Valkyrie::StorageAdapter"
  let(:storage_adapter) { described_class.new }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
  let(:version2) { fixture_file_upload('files/4-20.png', 'image/png') }
end
