# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::Persister do
  let(:adapter) do
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(
      connection: ::Ldp::Client.new("http://localhost:8988/rest"),
      base_path: "test_fed",
      schema: Valkyrie::Persistence::Fedora::PermissiveSchema.new(title: RDF::URI("http://bad.com/title"))
    )
  end
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }
  it_behaves_like "a Valkyrie::Persister"
  it_behaves_like "it supports persisting ordered properties"

  context "when given an id containing a slash" do
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

    it "can store the resource" do
      id = Valkyrie::ID.new("test/default")
      expect(id.to_s).to eq "test/default"
      persister.save(resource: resource_class.new(id: id))
      reloaded = query_service.find_by(id: id)
      expect(reloaded.id).to eq id
      expect(reloaded).to be_persisted
    end
  end

  context "when given multiple Times" do
    before do
      class CustomResource < Valkyrie::Resource
        attribute :times
      end
    end
    after do
      Object.send(:remove_const, :CustomResource)
    end
    it "works" do
      resource = CustomResource.new(times: [Time.now, Time.now - 5])

      output = persister.save(resource: resource)

      expect(output.times).to be_a Array
    end
  end

  context "when given an alternate identifier" do
    before do
      raise 'persister must be set with `let(:persister)`' unless defined? persister
      class CustomResource < Valkyrie::Resource
        include Valkyrie::Resource::AccessControls
        attribute :alternate_ids, Valkyrie::Types::Array
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

    it "creates an alternate identifier resource" do
      alternate_identifier = Valkyrie::ID.new("alternative")
      resource = resource_class.new
      resource.alternate_ids = [alternate_identifier]
      persister.save(resource: resource)

      alternate = query_service.find_by(id: alternate_identifier)
      expect(alternate.id).to eq alternate_identifier
      expect(alternate).to be_persisted
    end

    it "updates an alternate identifier resource" do
      alternate_identifier = Valkyrie::ID.new("alternative")
      resource = resource_class.new
      resource.alternate_ids = [alternate_identifier]
      reloaded = persister.save(resource: resource)

      alternate = query_service.find_by(id: alternate_identifier)
      expect(alternate.id).to eq alternate_identifier
      expect(alternate).to be_persisted

      alternate_identifier = Valkyrie::ID.new("alternate")
      reloaded.alternate_ids = [alternate_identifier]
      persister.save(resource: reloaded)
      expect(query_service.find_by_alternate_identifier(alternate_identifier: alternate_identifier).id).to eq reloaded.id
    end

    it "deletes the alternate identifier with the resource" do
      alternate_identifier = Valkyrie::ID.new("alternative")
      resource = resource_class.new
      resource.alternate_ids = [alternate_identifier]
      reloaded = persister.save(resource: resource)

      alternate = query_service.find_by(id: alternate_identifier)
      expect(alternate.id).to eq alternate_identifier
      expect(alternate).to be_persisted

      persister.delete(resource: reloaded)
      expect { query_service.find_by(id: alternate_identifier) }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
    end

    it "deletes removed alternate identifiers" do
      alternate_identifier = Valkyrie::ID.new("altfirst")
      second_alternate_identifier = Valkyrie::ID.new("altsecond")
      resource = resource_class.new
      resource.alternate_ids = [alternate_identifier, second_alternate_identifier]
      reloaded = persister.save(resource: resource)

      alternate = query_service.find_by(id: second_alternate_identifier)
      expect(alternate.id).to eq second_alternate_identifier
      expect(alternate).to be_persisted

      reload = query_service.find_by(id: reloaded.id)
      reload.alternate_ids = [alternate_identifier]
      persister.save(resource: reload)

      alternate = query_service.find_by(id: alternate_identifier)
      expect(alternate.id).to eq alternate_identifier
      expect(alternate).to be_persisted

      expect { query_service.find_by(id: second_alternate_identifier) }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
    end
  end
end
