# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::StorageAdapter::StreamFile do
  let(:io) { instance_double(StringIO) }
  let(:file) { described_class.new(id: "test_file", io: io) }
  it_behaves_like "a Valkyrie::StorageAdapter::File"
  describe '#disk_path' do
    before do
      allow(io).to receive(:read).and_return('Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
    end
    context 'with the disk or memory storage adapter' do
      it 'provides a path to the file for the storage adapter' do
        expect(file.disk_path).to be_a Pathname
      end
    end
  end
end
