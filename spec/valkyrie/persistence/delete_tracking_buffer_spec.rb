# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::DeleteTrackingBuffer do
  let(:adapter) { described_class.new }
  let(:query_service) { adapter.query_service }
  let(:persister) do
    adapter.persister
  end
  it_behaves_like "a Valkyrie::Persister"
  before do
    class Resource < Valkyrie::Resource
      include Valkyrie::Resource::AccessControls
      attribute :title
      attribute :member_ids
      attribute :nested_resource
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  it "tracks deletes" do
    obj = persister.save(resource: Resource.new)
    persister.delete(resource: obj)

    expect(persister.deletes).to eq [obj]
  end
end
