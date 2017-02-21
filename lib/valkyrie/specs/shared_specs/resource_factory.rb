# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::ResourceFactory' do
  before do
    class CustomResource
      include Valkyrie::ActiveModel
      attribute :id
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end

  describe ".from_model" do
    xit "creates a resource that can be fed into #to_model" do
      model = CustomResource.new(id: "test")
      orm_object = described_class.from_model(model)
      new_model = described_class.to_model(orm_object)

      expect(new_model.id).to eq model.id
      expect(new_model.class).to eq model.class
    end
  end
end
