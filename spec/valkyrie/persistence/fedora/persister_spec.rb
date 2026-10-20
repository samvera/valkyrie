# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::Persister, :wipe_fedora do
  [4, 6, 6.5].each do |fedora_version|
    context "fedora #{fedora_version}" do
      let(:version) { fedora_version }

      let(:adapter) do
        Valkyrie::Persistence::Fedora::MetadataAdapter.new(
          **fedora_adapter_config(
            base_path: "test_fed",
            schema: Valkyrie::Persistence::Fedora::PermissiveSchema.new(title: RDF::URI("http://example.com/title")),
            fedora_version: version
          )
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

      context "when given a Symbol" do
        before do
          raise 'persister must be set with `let(:persister)`' unless defined? persister
          class CustomResource < Valkyrie::Resource
            attribute :mode, Valkyrie::Types::Coercible::Symbol
          end
        end

        after do
          Object.send(:remove_const, :CustomResource)
        end

        let(:resource_class) { CustomResource }

        it "works" do
          id = Valkyrie::ID.new("test/symbol")
          resource = resource_class.new(id: id, mode: :read)
          persister.save(resource: resource)

          resource = query_service.find_by(id: id)
          expect(resource).to be_persisted
          expect(resource.mode).to eq :read
        end
      end

      context "when given a Hash" do
        before do
          class HashResource < Valkyrie::Resource
            attribute :a_hash, Valkyrie::Types::Hash.optional
          end

          class UntypedHashResource < Valkyrie::Resource
            attribute :entries
          end
        end

        after do
          Object.send(:remove_const, :HashResource)
          Object.send(:remove_const, :UntypedHashResource)
        end

        it "drops nil values from a hash in an untyped attribute, at every level" do
          entry = { name: "Ada", note: nil, source: { system: nil }, rows: [{ label: "x", note: nil }] }
          resource = UntypedHashResource.new(id: Valkyrie::ID.new("test/untyped-hash"), entries: [entry])
          persister.save(resource: resource)

          expect(query_service.find_by(id: resource.id).entries).to eq [{ name: "Ada", source: {}, rows: [{ label: "x" }] }]
        end

        it "stores it as one JSON literal" do
          resource = HashResource.new(a_hash: { path: "/one", tags: ["a"] })
          graph = Valkyrie::Persistence::Fedora::Persister::ModelConverter.new(resource: resource, adapter: adapter).convert.graph
          objects = graph.query([nil, RDF::URI("http://example.com/predicate/a_hash"), nil]).objects

          expect(objects.map(&:datatype)).to eq [Valkyrie::Persistence::Fedora::PermissiveSchema.valkyrie_json]
          expect(JSON.parse(objects.first.value)).to eq("path" => "/one", "tags" => ["a"])
        end
      end

      context "saving a server managed predicate" do
        before do
          raise 'persister must be set with `let(:persister)`' unless defined? persister
          class CustomResource < Valkyrie::Resource
            attribute :test_managed
          end
        end
        after do
          Object.send(:remove_const, :CustomResource)
        end
        let(:resource_class) { CustomResource }
        let(:adapter) do
          Valkyrie::Persistence::Fedora::MetadataAdapter.new(
            **fedora_adapter_config(
              base_path: "test_fed",
              schema: Valkyrie::Persistence::Fedora::PermissiveSchema.new(test_managed: RDF::Vocab::Fcrepo4.created),
              fedora_version: version
            )
          )
        end

        it "raises an error" do
          expect { persister.save(resource: resource_class.new(test_managed: 'whatever')) }.to raise_error ::Ldp::Conflict
        end
      end

      context "saving a fedora.info predicate that is not managed" do
        before do
          raise 'persister must be set with `let(:persister)`' unless defined? persister
          class CustomResource < Valkyrie::Resource
            attribute :state, Valkyrie::Types::URI
          end
        end
        after do
          Object.send(:remove_const, :CustomResource)
        end
        let(:resource_class) { CustomResource }
        let(:adapter) do
          Valkyrie::Persistence::Fedora::MetadataAdapter.new(
            **fedora_adapter_config(
              base_path: "test_fed",
              schema: Valkyrie::Persistence::Fedora::PermissiveSchema.new(
                state: RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#objState')
              ),
              fedora_version: version
            )
          )
        end

        it "succeeds" do
          id = persister.save(resource: resource_class.new(state: RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive'))).id
          expect(query_service.find_by(id: id).state).to eq RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive')
        end
      end

      context "when given an alternate identifier" do
        before do
          raise 'persister must be set with `let(:persister)`' unless defined? persister
          class CustomResource < Valkyrie::Resource
            include Valkyrie::Resource::AccessControls
            attribute :alternate_ids, Valkyrie::Types::Set.of(Valkyrie::Types::ID)
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

      context "using Fedora's builtin optimistic locking" do
        before do
          class FedoraLockingResource < Valkyrie::Resource
            enable_optimistic_locking
            attribute :title
          end
        end

        after do
          Object.send(:remove_const, :FedoraLockingResource)
        end

        it "does not raise an error when the object hasn't been updated by another client" do
          resource = persister.save(resource: FedoraLockingResource.new(title: ["Fedora Locking Resource"]))
          expect { persister.save(resource: resource) }.not_to raise_error
        end
        it "raises an error when saving an object that has been updated by another client" do
          resource = persister.save(resource: FedoraLockingResource.new(title: ["Fedora Locking Resource"]))

          # update a copy of the resource directly with orm to make sure our last-modified date is stale
          # but without invalidating our optimistic lock token
          sleep 1
          other_resource = resource.dup
          other_resource.title = ["Updated Locking Resource"]
          orm = adapter.resource_factory.from_resource(resource: other_resource)
          orm.update { |req| req.headers["Prefer"] = "handling=lenient; received=\"minimal\"" }

          expect { persister.save(resource: resource) }.to raise_error(Valkyrie::Persistence::StaleObjectError, "The object #{resource.id} has been updated by another process.")
        end
      end
    end
  end
end
