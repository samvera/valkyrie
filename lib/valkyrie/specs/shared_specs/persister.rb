# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Persister' do
  before do
    raise 'resource_class must be set with `let(:resource_class)`' unless
      defined? resource_class
  end
  let(:resource) { resource_class.new }

  it "can save a resource" do
    expect(described_class.save(resource).id).not_to be_blank
  end

  it "doesn't override a resource that already has an ID" do
    book = described_class.save(resource_class.new)
    id = book.id

    output = described_class.save(book)

    expect(output.id).to eq id
  end

  it "responds to .adapter" do
    expect(described_class.adapter).not_to be_blank
  end

  it "can find that resource again" do
    id = described_class.save(resource).id

    expect(QueryService.new(adapter: described_class.adapter).find_by_id(id)).to be_kind_of resource_class
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
      form = ResourceForm.new(Book.new)

      expect(described_class.save(form).id).not_to be_blank
    end
  end
end
