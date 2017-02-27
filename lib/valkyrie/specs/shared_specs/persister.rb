# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Persister' do
  before do
    raise 'persister must be set with `let(:persister)`' unless
      defined? persister
    class CustomResource
      include Valkyrie::ActiveModel
      attribute :id
      attribute :title
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

  context "when wrapped with a form object" do
    before do
      class ResourceForm < Valkyrie::Form
        self.fields = [:title]
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
