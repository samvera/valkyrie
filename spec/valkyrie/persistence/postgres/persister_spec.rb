# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::Persister do
  let(:query_service) { adapter.query_service }
  let(:adapter) { Valkyrie::Persistence::Postgres::MetadataAdapter.new }

  let(:persister) { adapter.persister }
  it_behaves_like "a Valkyrie::Persister"

  context "single value behavior" do
    before do
      class SingleResource < Valkyrie::Resource
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

  describe "save_all" do
    before do
      class CustomResource < Valkyrie::Resource
        include Valkyrie::Resource::AccessControls
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

    it "rolls back a transaction if something blows up" do
      resource1 = persister.save(resource: resource_class.new)
      resource1.author = "test"
      resource2 = resource_class.new
      allow(persister).to receive(:save).and_call_original
      allow(persister).to receive(:save).with(resource: resource2).and_raise

      expect { persister.save_all(resources: [resource1, resource2]) }.to raise_error RuntimeError
      expect(query_service.find_by(id: resource1.id).author).to be_nil
    end
  end

  context "when using an optimistically locked resource" do
    before do
      class MyLockingResource < Valkyrie::Resource
        enable_optimistic_locking
      end
    end
    after do
      Object.send(:remove_const, :MyLockingResource)
    end
    context "and the migrations haven't been run" do
      before do
        allow(adapter.resource_factory.orm_class).to receive(:column_names)
          .and_return(adapter.resource_factory.orm_class.column_names - ["lock_version"])
      end
      it "loads the object, but sends a warning with instructions" do
        resource = MyLockingResource.new
        expect { adapter.persister.save(resource: resource) }.to output(/\[MIGRATION REQUIRED\]/).to_stderr
      end
    end
  end
end
