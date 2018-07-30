# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::Persister do
  let(:query_service) { adapter.query_service }
  let(:adapter) { Valkyrie::Persistence::Postgres::MetadataAdapter.new }

  let(:persister) { adapter.persister }
  it_behaves_like "a Valkyrie::Persister"
  it_behaves_like "it supports single values"

  context "single value behavior" do
    before do
      class SingleResource < Valkyrie::Resource
        attribute :id, Valkyrie::Types::ID.optional
        attribute :single_value, Valkyrie::Types::String
      end
    end
    after do
      Object.send(:remove_const, :SingleResource)
    end
    it "stores single values as multiple" do
      resource = SingleResource.new(single_value: "Test")
      output = persister.save(resource: resource)

      orm_resource = query_service.resource_factory.from_resource(resource: output)

      expect(orm_resource.metadata["single_value"]).to eq ["Test"]
    end
  end
  context "converting a DateTime" do
    before do
      raise 'persister must be set with `let(:persister)`' unless defined? persister
      class CustomResource < Valkyrie::Resource
        include Valkyrie::Resource::AccessControls
        attribute :id, Valkyrie::Types::ID.optional
        attribute :title
        attribute :author
        attribute :member_ids
        attribute :nested_resource
      end
    end
    after do
      Object.send(:remove_const, :CustomResource)
    end
    let(:resource_class) { CustomResource }

    it "Returns a string when DateTime conversion fails" do
      time1 = DateTime.current
      time2 = Time.current.in_time_zone
      allow(DateTime).to receive(:iso8601).and_raise StandardError.new("bogus exception")
      book = persister.save(resource: resource_class.new(title: [time1], author: [time2]))

      reloaded = query_service.find_by(id: book.id)

      expect(reloaded.title.first[0, 18]).to eq(time1.to_s[0, 18])
    end
  end
end
