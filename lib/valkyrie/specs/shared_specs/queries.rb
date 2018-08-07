# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie query provider' do
  before do
    raise 'adapter must be set with `let(:adapter)`' unless
      defined? adapter
    class CustomResource < Valkyrie::Resource
      attribute :alternate_ids, Valkyrie::Types::Array
      attribute :title
      attribute :member_ids, Valkyrie::Types::Array
      attribute :a_member_of
    end
    class SecondResource < Valkyrie::Resource
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
    Object.send(:remove_const, :SecondResource)
  end
  let(:resource_class) { CustomResource }
  let(:query_service) { adapter.query_service } unless defined? query_service
  let(:persister) { adapter.persister }
  subject { adapter.query_service }

  it { is_expected.to respond_to(:find_all).with(0).arguments }
  it { is_expected.to respond_to(:find_all_of_model).with_keywords(:model) }
  it { is_expected.to respond_to(:find_by).with_keywords(:id) }
  it { is_expected.to respond_to(:find_by_alternate_identifier).with_keywords(:alternate_identifier) }
  it { is_expected.to respond_to(:find_many_by_ids).with_keywords(:ids) }
  it { is_expected.to respond_to(:find_members).with_keywords(:resource, :model) }
  it { is_expected.to respond_to(:find_references_by).with_keywords(:resource, :property) }
  it { is_expected.to respond_to(:find_inverse_references_by).with_keywords(:resource, :property) }
  it { is_expected.to respond_to(:find_parents).with_keywords(:resource) }

  describe ".find_all" do
    it "returns all created resources" do
      resource1 = persister.save(resource: resource_class.new)
      resource2 = persister.save(resource: resource_class.new)

      expect(query_service.find_all.map(&:id)).to contain_exactly resource1.id, resource2.id
    end
  end

  describe ".find_all_of_model" do
    it "returns all of that model" do
      persister.save(resource: resource_class.new)
      resource2 = persister.save(resource: SecondResource.new)

      expect(query_service.find_all_of_model(model: SecondResource).map(&:id)).to contain_exactly resource2.id
    end
    it "returns an empty array if there are none" do
      expect(query_service.find_all_of_model(model: SecondResource).to_a).to eq []
    end
  end

  describe ".find_by" do
    it "returns a resource by id or string representation of an id" do
      resource = persister.save(resource: resource_class.new)

      found = query_service.find_by(id: resource.id)
      expect(found.id).to eq resource.id
      expect(found).to be_persisted

      found = query_service.find_by(id: resource.id.to_s)
      expect(found.id).to eq resource.id
      expect(found).to be_persisted
    end

    it "returns a Valkyrie::Persistence::ObjectNotFoundError for a non-found ID" do
      expect { query_service.find_by(id: Valkyrie::ID.new("123123123")) }.to raise_error ::Valkyrie::Persistence::ObjectNotFoundError
    end

    it 'raises an error if the id is not a Valkyrie::ID or a string' do
      expect { query_service.find_by(id: 123) }.to raise_error ArgumentError
    end
  end

  describe ".find_by_alternate_identifier" do
    it "returns a resource by alternate identifier or string representation of an alternate identifier" do
      resource = resource_class.new
      resource.alternate_ids = [Valkyrie::ID.new('p9s0xfj')]
      resource = persister.save(resource: resource)

      found = query_service.find_by_alternate_identifier(alternate_identifier: resource.alternate_ids.first)
      expect(found.id).to eq resource.id
      expect(found).to be_persisted

      found = query_service.find_by_alternate_identifier(alternate_identifier: resource.alternate_ids.first.to_s)
      expect(found.id).to eq resource.id
      expect(found).to be_persisted
    end

    it "returns a Valkyrie::Persistence::ObjectNotFoundError for a non-found alternate identifier" do
      expect { query_service.find_by_alternate_identifier(alternate_identifier: Valkyrie::ID.new("123123123")) }.to raise_error ::Valkyrie::Persistence::ObjectNotFoundError
    end

    it 'raises an error if the alternate identifier is not a Valkyrie::ID or a string' do
      expect { query_service.find_by_alternate_identifier(alternate_identifier: 123) }.to raise_error ArgumentError
    end

    it 'can have multiple alternate identifiers' do
      resource = resource_class.new
      resource.alternate_ids = [Valkyrie::ID.new('p9s0xfj'), Valkyrie::ID.new('jks0xfj')]
      resource = persister.save(resource: resource)

      found = query_service.find_by_alternate_identifier(alternate_identifier: resource.alternate_ids.first)
      expect(found.id).to eq resource.id
      expect(found).to be_persisted

      found = query_service.find_by_alternate_identifier(alternate_identifier: resource.alternate_ids.last)
      expect(found.id).to eq resource.id
      expect(found).to be_persisted
    end
  end

  describe ".find_many_by_ids" do
    let!(:resource) { persister.save(resource: resource_class.new) }
    let!(:resource2) { persister.save(resource: resource_class.new) }
    let!(:resource3) { persister.save(resource: resource_class.new) }

    it "returns an array of resources by ids or string representation ids" do
      found = query_service.find_many_by_ids(ids: [resource.id, resource2.id])
      expect(found.map(&:id)).to contain_exactly resource.id, resource2.id

      found = query_service.find_many_by_ids(ids: [resource.id.to_s, resource2.id.to_s])
      expect(found.map(&:id)).to contain_exactly resource.id, resource2.id
    end

    it "returns a partial list for a non-found ID" do
      found = query_service.find_many_by_ids(ids: [resource.id, Valkyrie::ID.new("123123123")])
      expect(found.map(&:id)).to contain_exactly resource.id
    end

    it "returns an empty list if no ids were found" do
      found = query_service.find_many_by_ids(ids: [Valkyrie::ID.new("you-cannot-find-me"), Valkyrie::ID.new("123123123")])
      expect(found.map(&:id)).to eq []
    end

    it 'raises an error if any id is not a Valkyrie::ID or a string' do
      expect { query_service.find_many_by_ids(ids: [resource.id, 123]) }.to raise_error ArgumentError
    end
  end

  describe ".find_members" do
    context "without filtering by model" do
      subject { query_service.find_members(resource: parent) }

      context "when the object has members" do
        let!(:child1) { persister.save(resource: resource_class.new) }
        let!(:child2) { persister.save(resource: resource_class.new) }
        let(:parent) { persister.save(resource: resource_class.new(member_ids: [child2.id, child1.id])) }

        it "returns all a resource's members in order" do
          expect(subject.map(&:id).to_a).to eq [child2.id, child1.id]
        end
      end

      context "when there's no resource ID" do
        let(:parent) { resource_class.new }

        it "doesn't error" do
          expect(subject).not_to eq nil
          expect(subject.to_a).to eq []
        end
      end

      context "when there are no members" do
        let(:parent) { persister.save(resource: resource_class.new) }

        it "returns an empty array" do
          expect(subject.to_a).to eq []
        end
      end

      context "when the model doesn't have member_ids" do
        let(:parent) { persister.save(resource: SecondResource.new) }

        it "returns an empty array" do
          expect(subject.to_a).to eq []
        end
      end
    end

    context "filtering by model" do
      subject { query_service.find_members(resource: parent, model: SecondResource) }

      context "when the object has members" do
        let(:child1) { persister.save(resource: SecondResource.new) }
        let(:child2) { persister.save(resource: resource_class.new) }
        let(:child3) { persister.save(resource: SecondResource.new) }
        let(:parent) { persister.save(resource: resource_class.new(member_ids: [child3.id, child2.id, child1.id])) }

        it "returns all a resource's members in order" do
          expect(subject.map(&:id).to_a).to eq [child3.id, child1.id]
        end
      end

      context "when there are no members that match the filter" do
        let(:child1) { persister.save(resource: resource_class.new) }
        let(:parent) { persister.save(resource: resource_class.new(member_ids: [child1.id])) }

        it "returns an empty array" do
          expect(subject.to_a).to eq []
        end
      end
    end
  end

  describe ".find_references_by" do
    it "returns all references given in a property" do
      parent = persister.save(resource: resource_class.new)
      child = persister.save(resource: resource_class.new(a_member_of: [parent.id]))
      persister.save(resource: resource_class.new)

      expect(query_service.find_references_by(resource: child, property: :a_member_of).map(&:id).to_a).to eq [parent.id]
    end
    it "returns an empty array if there are none" do
      child = persister.save(resource: resource_class.new)
      expect(query_service.find_references_by(resource: child, property: :a_member_of).to_a).to eq []
    end
  end

  describe ".find_inverse_references_by" do
    context "when the resource is saved" do
      it "returns everything which references the given resource by the given property" do
        parent = persister.save(resource: resource_class.new)
        child = persister.save(resource: resource_class.new(a_member_of: [parent.id]))
        persister.save(resource: resource_class.new)
        persister.save(resource: SecondResource.new)

        expect(query_service.find_inverse_references_by(resource: parent, property: :a_member_of).map(&:id).to_a).to eq [child.id]
      end
      it "returns an empty array if there are none" do
        parent = persister.save(resource: resource_class.new)

        expect(query_service.find_inverse_references_by(resource: parent, property: :a_member_of).to_a).to eq []
      end
    end
    context "when the resource is not saved" do
      it "raises an error" do
        parent = resource_class.new

        expect { query_service.find_inverse_references_by(resource: parent, property: :a_member_of).to_a }.to raise_error ArgumentError
      end
    end
  end

  describe ".find_parents" do
    it "returns all parent resources" do
      child1 = persister.save(resource: resource_class.new)
      child2 = persister.save(resource: resource_class.new)
      parent = persister.save(resource: resource_class.new(member_ids: [child1.id, child2.id]))
      parent2 = persister.save(resource: resource_class.new(member_ids: [child1.id]))

      expect(query_service.find_parents(resource: child1).map(&:id).to_a).to contain_exactly parent.id, parent2.id
    end
    it "returns an empty array if there are none" do
      child1 = persister.save(resource: resource_class.new)

      expect(query_service.find_parents(resource: child1).to_a).to eq []
    end

    context "when the model doesn't have member_ids" do
      let(:child1) { persister.save(resource: SecondResource.new) }

      it "returns an empty array if there are none" do
        expect(query_service.find_parents(resource: child1).to_a).to eq []
      end
    end
  end

  describe ".register_query_handler" do
    it "can register a query handler" do
      class QueryHandler
        def self.queries
          [:find_by_user_id]
        end

        attr_reader :query_service
        def initialize(query_service:)
          @query_service = query_service
        end

        def find_by_user_id
          1
        end
      end
      query_service.custom_queries.register_query_handler(QueryHandler)
      expect(query_service.custom_queries).to respond_to :find_by_user_id
      expect(query_service.custom_queries.find_by_user_id).to eq 1
    end
  end

  context "optimistic locking" do
    before do
      class CustomLockingQueryResource < Valkyrie::Resource
        enable_optimistic_locking
        attribute :title
      end
    end
    after do
      Object.send(:remove_const, :CustomLockingQueryResource)
    end

    it "retrieves the lock token and casts it to optimistic_lock_token attribute" do
      resource = CustomLockingQueryResource.new(title: "My Title")
      resource = persister.save(resource: resource)
      resource = query_service.find_by(id: resource.id)
      # we can't know the value in the general case
      expect(resource[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK]).not_to be_empty
    end
  end
end
