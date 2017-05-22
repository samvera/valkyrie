# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Model' do
  before do
    raise 'model_klass must be set with `let(:model_klass)`' unless
      defined? model_klass
  end
  describe "#id" do
    it "can be set via instantiation and casts to a Valkyrie::ID" do
      resource = model_klass.new(id: "test")
      expect(resource.id).to eq Valkyrie::ID.new("test")
    end

    it "is nil when not set" do
      resource = model_klass.new
      expect(resource.id).to be_nil
    end

    it { is_expected.to respond_to(:persisted?).with(0).arguments }
    it { is_expected.to respond_to(:to_param).with(0).arguments }
    it { is_expected.to respond_to(:to_model).with(0).arguments }
    it { is_expected.to respond_to(:model_name).with(0).arguments }
    it { is_expected.to respond_to(:resource_class).with(0).arguments }
    it { is_expected.to respond_to(:column_for_attribute).with(1).arguments }

    describe "#has_attribute?" do
      it "returns true when it has a given attribute" do
        resource = model_klass.new
        expect(resource.has_attribute?(:id)).to eq true
      end
    end

    describe "#fields" do
      it "returns a set of fields" do
        expect(model_klass).to respond_to(:fields).with(0).arguments
        expect(model_klass.fields).to include(:id)
      end
    end

    describe "#attributes" do
      it "returns a list of all set attributes" do
        resource = model_klass.new(id: "test")
        expect(resource.attributes[:id].to_s).to eq "test"
      end
    end
  end
end
