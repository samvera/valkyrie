# frozen_string_literal: true
RSpec.shared_examples 'a Penguin::Persister' do
  before do
    raise 'persister must be set with `let(:persister)`' unless
      defined? persister
    class CustomResource
      include Penguin::ActiveModel
      attribute :id
      attribute :title
      attribute :member_ids
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end
  let(:resource) { CustomResource.new }
  let(:resource_class) { CustomResource }

  it "can save a resource" do
    expect(persister.save(resource).id).not_to be_blank
  end

  it "can handle language-typed RDF properties" do
    book = persister.save(resource_class.new(title: ["Test1", RDF::Literal.new("Test", language: :fr)]))

    reloaded = QueryService.new(adapter: persister.adapter).find_by_id(book.id)

    expect(reloaded.title).to contain_exactly "Test1", RDF::Literal.new("Test", language: :fr)
  end

  it "can order members" do
    book = persister.save(resource_class.new)
    book2 = persister.save(resource_class.new)
    book3 = persister.save(resource_class.new)
    parent = persister.save(resource_class.new(member_ids: [book2.id, book.id, book3.id]))

    reloaded = QueryService.new(adapter: persister.adapter).find_by_id(parent.id)
    expect(reloaded.member_ids).to eq [book2.id, book.id, book3.id]
  end

  it "doesn't override a resource that already has an ID" do
    book = persister.save(resource_class.new)
    id = book.id

    output = persister.save(book)

    expect(output.id).to eq id
  end

  it "responds to .adapter" do
    expect(persister.adapter).not_to be_blank
  end

  it "can find that resource again" do
    id = persister.save(resource).id

    expect(QueryService.new(adapter: persister.adapter).find_by_id(id)).to be_kind_of resource_class
  end

  it "can delete objects" do
    persisted = persister.save(resource)
    query_service = persister.adapter.query_service
    persister.delete(persisted)

    expect { query_service.find_by_id(persisted.id) }.to raise_error ::Persister::ObjectNotFoundError
  end

  context "when wrapped with a form object" do
    before do
      class ResourceForm < Penguin::Form
        self.fields = [:title, :member_ids]
      end
    end
    after do
      Object.send(:remove_const, :ResourceForm)
    end
    it "works" do
      form = ResourceForm.new(CustomResource.new)

      expect(persister.save(form).id).not_to be_blank
    end
  end
end
