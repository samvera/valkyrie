# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::StorageAdapter::File do
  let(:io) do
    File.open(Valkyrie::Engine.root.join("spec", "fixtures", "files", "example.tif"))
  end
  let(:file) { described_class.new(id: "test_file", io: io) }
  it_behaves_like "a Valkyrie::StorageAdapter::File"

  describe '#disk_path' do
    context 'with the disk or memory storage adapter' do
      it 'provides a path to the file for the storage adapter' do
        expect(file.disk_path).to eq Pathname.new(io.path)
      end
    end
  end
end
