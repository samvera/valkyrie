# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Persister' do |*flags|
  before do
    raise 'persister must be set with `let(:persister)`' unless defined? persister
    class CustomResource < Valkyrie::Model
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title
      attribute :member_ids
      attribute :nested_resource
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end

  subject { persister }
  let(:resource_class) { CustomResource }
  let(:resource) { resource_class.new }
  let(:query_service) { persister.adapter.query_service }

  it { is_expected.to respond_to(:save).with_keywords(:model) }
  it { is_expected.to respond_to(:delete).with_keywords(:model) }

  it "can save a resource" do
    expect(persister.save(model: resource).id).not_to be_blank
  end

  it "can save nested resources" do
    book2 = resource_class.new(title: "Nested")
    book3 = persister.save(model: resource_class.new(nested_resource: book2))

    reloaded = query_service.find_by(id: book3.id)
    expect(reloaded.nested_resource.first.title).to eq ["Nested"]
  end

  it "can mix properties with nested resources" do
    pending "No support for mixed nesting." if flags.include?(:no_mixed_nesting)
    book2 = resource_class.new(title: "Nested")
    book3 = persister.save(model: resource_class.new(nested_resource: [book2, "Alabama"]))

    reloaded = query_service.find_by(id: book3.id)
    expect(reloaded.nested_resource.map { |x| x.try(:title) }).to include ["Nested"]
    expect(reloaded.nested_resource).to include "Alabama"
  end

  it "can support deep nesting of resources" do
    pending "No support for deep nesting." if flags.include?(:no_deep_nesting)
    book = resource_class.new(title: "Sub-nested")
    book2 = resource_class.new(title: "Nested", nested_resource: book)
    book3 = persister.save(model: resource_class.new(nested_resource: book2))

    reloaded = query_service.find_by(id: book3.id)
    expect(reloaded.nested_resource.first.title).to eq ["Nested"]
    expect(reloaded.nested_resource.first.nested_resource.first.title).to eq ["Sub-nested"]
  end

  it "stores created_at/updated_at" do
    book = persister.save(model: resource_class.new)
    book.title = "test"
    book = persister.save(model: book)
    expect(book.created_at).not_to be_blank
    expect(book.updated_at).not_to be_blank
    expect(book.created_at).not_to be_kind_of Array
    expect(book.updated_at).not_to be_kind_of Array
  end

  it "can handle language-typed RDF properties" do
    book = persister.save(model: resource_class.new(title: ["Test1", RDF::Literal.new("Test", language: :fr)]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly "Test1", RDF::Literal.new("Test", language: :fr)
  end

  it "can store Valkyrie::Ids" do
    shared_title = persister.save(model: resource_class.new(id: "test"))
    book = persister.save(model: resource_class.new(title: [shared_title.id, Valkyrie::ID.new("adapter://1"), "test"]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly(shared_title.id, Valkyrie::ID.new("adapter://1"), "test")
    expect([shared_title.id, Valkyrie::ID.new("adapter://1"), "test"]).to contain_exactly(*reloaded.title)
  end

  it "can store ::RDF::URIs" do
    book = persister.save(model: resource_class.new(title: [::RDF::URI("http://test.com")]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly RDF::URI("http://test.com")
  end

  it "can store integers" do
    book = persister.save(model: resource_class.new(title: [1]))
    reloaded = query_service.find_by(id: book.id)
    expect(reloaded.title).to contain_exactly 1
  end

  context "parent tests" do
    let(:book) { persister.save(model: resource_class.new) }
    let(:book2) { persister.save(model: resource_class.new) }

    it "can order members" do
      book3 = persister.save(model: resource_class.new)
      parent = persister.save(model: resource_class.new(member_ids: [book2.id, book.id]))
      parent.member_ids = parent.member_ids + [book3.id]
      parent = persister.save(model: parent)
      reloaded = query_service.find_by(id: parent.id)
      expect(reloaded.member_ids).to eq [book2.id, book.id, book3.id]
    end

    it "can remove members" do
      parent = persister.save(model: resource_class.new(member_ids: [book2.id, book.id]))
      parent.member_ids = parent.member_ids - [book2.id]
      parent = persister.save(model: parent)
      expect(parent.member_ids).to eq [book.id]
    end
  end

  it "doesn't override a resource that already has an ID" do
    book = persister.save(model: resource_class.new)
    id = book.id
    output = persister.save(model: book)
    expect(output.id).to eq id
  end

  it "responds to .adapter" do
    expect(persister.adapter).not_to be_blank
  end

  it "can find that resource again" do
    id = persister.save(model: resource).id
    expect(persister.adapter.query_service.find_by(id: id)).to be_kind_of resource_class
  end

  it "can delete objects" do
    persisted = persister.save(model: resource)
    query_service = persister.adapter.query_service
    persister.delete(model: persisted)
    expect { query_service.find_by(id: persisted.id) }.to raise_error ::Valkyrie::Persistence::ObjectNotFoundError
  end

  context "when wrapped with a form object" do
    let(:myclass) { Class.new(Valkyrie::Form) { self.fields = [:title, :member_ids] } }
    let(:form) { myclass.new(resource_class.new) }

    it "works" do
      expect(persister.save(model: form).id).not_to be_blank
    end
    it "doesn't return a form object" do
      persisted = persister.save(model: form)
      reloaded = query_service.find_by(id: persisted.id)
      expect(reloaded).to be_kind_of(resource_class)
    end
  end
end
