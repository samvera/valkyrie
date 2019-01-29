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

  describe "#[]" do
    it "allows access to properties which are set" do
      resource_klass.attribute :my_property
      resource = resource_klass.new

      resource.my_property = "test"

      expect(resource[:my_property]).to eq ["test"]
      resource_klass.schema.delete(:my_property)
    end
    it "returns nil for non-existent properties" do
      resource = resource_klass.new

      expect(resource[:bad_property]).to eq nil
    end
    it "can be accessed via a string" do
      resource_klass.attribute :other_property
      resource = resource_klass.new

      resource.other_property = "test"

      expect(resource["other_property"]).to eq ["test"]
      resource_klass.schema.delete(:other_property)
    end
  end

  describe "#set_value" do
    it "can set a value" do
      resource_klass.attribute :set_value_property
      resource = resource_klass.new

      resource.set_value(:set_value_property, "test")

      expect(resource.set_value_property).to eq ["test"]
      resource.set_value("set_value_property", "testing")
      expect(resource.set_value_property).to eq ["testing"]
      resource_klass.schema.delete(:set_value_property)
    end
  end

  describe ".new" do
    it "can set values with symbols" do
      resource_klass.attribute :symbol_property

      resource = resource_klass.new(symbol_property: "bla")

      expect(resource.symbol_property).to eq ["bla"]
      resource_klass.schema.delete(:symbol_property)
    end
    it "can not set values with string properties" do
      resource_klass.attribute :string_property

      resource = nil
      expect(resource).not_to respond_to :string_property
      resource_klass.schema.delete(:string_property)
    end
  end

  describe "#attributes" do
    it "returns all defined attributs, including nil keys" do
      resource_klass.attribute :bla

      resource = resource_klass.new

      expect(resource.attributes).to be_frozen
      expect(resource.attributes).to have_key(:bla)
      expect(resource.attributes[:internal_resource]).to eq resource_klass.to_s
      expect { resource.attributes.dup[:internal_resource] = "bla" }.not_to output.to_stderr

      resource_klass.schema.delete(:bla)
    end
  end
end
