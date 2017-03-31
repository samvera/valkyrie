# frozen_string_literal: true
RSpec.shared_examples 'a Penguin::ResourceFactory' do
  before do
    class CustomResource
      include Penguin::ActiveModel
      attribute :id
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end

  it "responds to adapter" do
    expect(described_class.adapter).not_to be_nil
  end

  describe ".from_model" do
    it "creates a resource that can be fed into #to_model" do
      model = Persister.new(adapter: described_class.adapter).save(CustomResource.new)
      orm_object = described_class.from_model(model)
      new_model = described_class.to_model(orm_object)

      expect(new_model.id).to eq model.id
      expect(new_model.class).to eq model.class
    end
  end
end
