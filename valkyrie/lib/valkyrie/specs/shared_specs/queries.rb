# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie query provider' do
  before do
    raise 'adapter must be set with `let(:adapter)`' unless
      defined? adapter
    class CustomResource < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title
      attribute :member_ids
      attribute :a_member_of
    end
    class SecondResource < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
    Object.send(:remove_const, :SecondResource)
  end
  let(:resource_class) { CustomResource }
  let(:query_service) { adapter.query_service }
  let(:persister) { adapter.persister }
  subject { adapter.query_service }

  it { is_expected.to respond_to(:find_all).with(0).arguments }
  it { is_expected.to respond_to(:find_all_of_resource).with_keywords(:resource) }
  it { is_expected.to respond_to(:find_by).with_keywords(:id) }
  it { is_expected.to respond_to(:find_members).with_keywords(:resource) }
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

  describe ".find_all_of_resource" do
    it "returns all of that resource" do
      persister.save(resource: resource_class.new)
      resource2 = persister.save(resource: SecondResource.new)

      expect(query_service.find_all_of_resource(resource: SecondResource).map(&:id)).to contain_exactly resource2.id
    end
  end

  describe ".find_by" do
    it "returns a resource by id" do
      resource = persister.save(resource: resource_class.new)

      expect(query_service.find_by(id: resource.id).id).to eq resource.id
    end
    it "returns a Valkyrie::Persistence::ObjectNotFoundError for a non-found ID" do
      expect { query_service.find_by(id: "123123123") }.to raise_error ::Valkyrie::Persistence::ObjectNotFoundError
    end
  end

  describe ".find_members" do
    it "returns all a resource's members in order" do
      child1 = persister.save(resource: resource_class.new)
      child2 = persister.save(resource: resource_class.new)
      parent = persister.save(resource: resource_class.new(member_ids: [child2.id, child1.id]))

      expect(query_service.find_members(resource: parent).map(&:id).to_a).to eq [child2.id, child1.id]
      expect(query_service.find_by(id: parent.id).member_ids).to eq [child2.id, child1.id]
    end
    it "doesn't error when there's no resource ID" do
      parent = resource_class.new
      expect(query_service.find_members(resource: parent).to_a).to eq []
    end
  end

  describe ".find_references_by" do
    it "returns all references given in a property" do
      parent = persister.save(resource: resource_class.new)
      child = persister.save(resource: resource_class.new(a_member_of: [parent.id]))
      persister.save(resource: resource_class.new)

      expect(query_service.find_references_by(resource: child, property: :a_member_of).map(&:id).to_a).to eq [parent.id]
    end
  end

  describe ".find_inverse_references_by" do
    it "returns everything which references the given resource by the given property" do
      parent = persister.save(resource: resource_class.new)
      child = persister.save(resource: resource_class.new(a_member_of: [parent.id]))
      persister.save(resource: resource_class.new)

      expect(query_service.find_inverse_references_by(resource: parent, property: :a_member_of).map(&:id).to_a).to eq [child.id]
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
  end
end
