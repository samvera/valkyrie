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

  context "when given an id containing a slash" do
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

    it "can store the resource" do
      id = Valkyrie::ID.new("test/default")
      expect(id.to_s).to eq "test/default"
      persister.save(resource: resource_class.new(id: id))
      reloaded = query_service.find_by(id: id)
      expect(reloaded.id).to eq id
      expect(reloaded).to be_persisted
    end
  end
end
