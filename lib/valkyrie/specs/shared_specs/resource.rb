# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Resource' do
  before do
    raise 'resource_klass must be set with `let(:resource_klass)`' unless
      defined? resource_klass
  end
  describe "#id" do
    it "can be set via instantiation and casts to a Valkyrie::ID" do
      resource = resource_klass.new(id: "test")
      expect(resource.id).to eq Valkyrie::ID.new("test")
    end

    it "is nil when not set" do
      resource = resource_klass.new
      expect(resource.id).to be_nil
    end

    it { is_expected.to respond_to(:persisted?).with(0).arguments }
    it { is_expected.to respond_to(:to_param).with(0).arguments }
    it { is_expected.to respond_to(:to_model).with(0).arguments }
    it { is_expected.to respond_to(:model_name).with(0).arguments }
    it { is_expected.to respond_to(:column_for_attribute).with(1).arguments }

    describe "#has_attribute?" do
      it "returns true when it has a given attribute" do
        resource = resource_klass.new
        expect(resource.has_attribute?(:id)).to eq true
      end
    end

    describe "#fields" do
      it "returns a set of fields" do
        expect(resource_klass).to respond_to(:fields).with(0).arguments
        expect(resource_klass.fields).to include(:id)
      end
    end

    describe "#attributes" do
      it "returns a list of all set attributes" do
        resource = resource_klass.new(id: "test")
        expect(resource.attributes[:id].to_s).to eq "test"
      end
    end
  end

  describe "#internal_resource" do
    it "is set to the resource's class on instantiation" do
      resource = resource_klass.new
      expect(resource.internal_resource).to eq resource_klass.to_s
    end
  end

  describe "#human_readable_type" do
    before do
      class MyCustomResource < Valkyrie::Resource
        attribute :title, Valkyrie::Types::Set
      end
    end

    after do
      Object.send(:remove_const, :MyCustomResource)
    end

    subject(:my_custom_resource) { MyCustomResource.new }

    it "returns a human readable rendering of the resource class" do
      expect(my_custom_resource.human_readable_type).to eq "My Custom Resource"
    end
  end
end
