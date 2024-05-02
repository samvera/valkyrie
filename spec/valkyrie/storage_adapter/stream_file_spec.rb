# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::StorageAdapter::StreamFile do
  let(:io) { StringIO.new("Loreim ipsum dolor sit amet, consectur apidiscing elit.") }
  let(:file) { described_class.new(id: "test_file", io: io) }
  it_behaves_like "a Valkyrie::StorageAdapter::File"
  describe '#disk_path' do
    context 'with the disk or memory storage adapter' do
      it 'provides a path to the file for the storage adapter' do
        expect(file.disk_path).to be_a Pathname
      end
    end
    it "cleans up any tmp files when using a block" do
      disk_path = nil
      file.disk_path do |f_path|
        disk_path = f_path
      end
      expect(File.exist?(disk_path)).to eq false
    end
    it "cleans up tmp files when closing the reference" do
      path = file.disk_path
      file.close
      expect(File.exist?(path)).to eq false
    end
  end
end
