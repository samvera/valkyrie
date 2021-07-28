# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::BufferedPersister do
  let(:adapter) { Valkyrie::Persistence::Memory::MetadataAdapter.new }
  let(:query_service) { adapter.query_service }
  let(:persister) do
    described_class.new(
      adapter.persister
    )
  end
  before do
    class Resource < Valkyrie::Resource
      attribute :title
      attribute :member_ids
      attribute :nested_resource
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  it_behaves_like "a Valkyrie::Persister"
  describe "#with_buffer" do
    it "can buffer a session into a memory adapter" do
      buffer = nil
      persister.with_buffer do |inner_persister, memory_buffer|
        inner_persister.save(resource: Resource.new)
        buffer = memory_buffer
      end
      expect(buffer.query_service.find_all.length).to eq 1
    end
    it "can handle saving an object which was previously saved" do
      buffer = nil
      resource = Resource.new
      output = adapter.persister.save(resource: resource)
      persister.with_buffer do |inner_persister, memory_buffer|
        inner_persister.save(resource: output)
        buffer = memory_buffer
      end
      expect(buffer.query_service.find_all.length).to eq 1
    end
  end
end
