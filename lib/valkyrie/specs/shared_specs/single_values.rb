# frozen_string_literal: true
RSpec.shared_examples 'it supports single values' do
  before do
    raise 'persister must be set with `let(:persister)`' unless defined? persister
    class CustomResource < Valkyrie::Resource
      include Valkyrie::Resource::AccessControls
      attribute :id, Valkyrie::Types::ID.optional
      attribute :single_value, Valkyrie::Types::String.optional
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end

  subject { persister }
  let(:resource_class) { CustomResource }
  let(:resource) { resource_class.new }

  it "can persist single values" do
    resource.single_value = "A single value"

    output = persister.save(resource: resource)

    expect(output.single_value).to eq "A single value"
  end
end
