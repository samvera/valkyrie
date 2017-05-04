# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie query provider' do
  before do
    raise 'adapter must be set with `let(:adapter)`' unless
      defined? adapter
    raise 'resource_class must be set with `let(:resource_class)`' unless
      defined? resource_class
  end
  let(:query_service) { adapter.query_service }
  let(:persister) { adapter.persister }
  subject { adapter.query_service }

  it { is_expected.to respond_to(:find_all).with(0).arguments }
  it { is_expected.to respond_to(:find_by).with_keywords(:id) }
  it { is_expected.to respond_to(:find_members).with_keywords(:model) }
  it { is_expected.to respond_to(:find_parents).with_keywords(:model) }

  describe ".find_all" do
    it "returns all created resources" do
      resource1 = persister.save(model: resource_class.new)
      resource2 = persister.save(model: resource_class.new)

      expect(query_service.find_all.map(&:id)).to contain_exactly resource1.id, resource2.id
    end
  end

  describe ".find_by" do
    it "returns a resource by id" do
      resource = persister.save(model: resource_class.new)

      expect(query_service.find_by(id: resource.id).id).to eq resource.id
    end
    it "returns a ::Persister::ObjectNotFoundError for a non-found ID" do
      expect { query_service.find_by(id: "123123123") }.to raise_error ::Persister::ObjectNotFoundError
    end
  end

  describe ".find_members" do
    it "returns all a resource's members in order" do
      child1 = persister.save(model: resource_class.new)
      child2 = persister.save(model: resource_class.new)
      parent = persister.save(model: resource_class.new(member_ids: [child2.id, child1.id]))

      expect(query_service.find_members(model: parent).map(&:id).to_a).to eq [child2.id, child1.id]
      expect(query_service.find_by(id: parent.id).member_ids).to eq [child2.id, child1.id]
    end
    it "doesn't error when there's no model ID" do
      parent = resource_class.new
      expect(query_service.find_members(model: parent).to_a).to eq []
    end
  end

  describe ".find_parents" do
    it "returns all parent resources" do
      child1 = persister.save(model: resource_class.new)
      child2 = persister.save(model: resource_class.new)
      parent = persister.save(model: resource_class.new(member_ids: [child1.id, child2.id]))
      parent2 = persister.save(model: resource_class.new(member_ids: [child1.id]))

      expect(query_service.find_parents(model: child1).map(&:id).to_a).to contain_exactly parent.id, parent2.id
    end
  end
end
