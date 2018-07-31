# frozen_string_literal: true
RSpec.shared_examples 'it supports persisting ordered properties' do
  before do
    raise 'persister must be set with `let(:persister)`' unless defined? persister
    class CustomResource < Valkyrie::Resource
      include Valkyrie::Resource::AccessControls
      attribute :id, Valkyrie::Types::ID.optional
      attribute :authors, Valkyrie::Types::Array.optional.meta(ordered: true)
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end

  subject { persister }
  let(:resource_class) { CustomResource }
  let(:resource) { resource_class.new }

  it "saves ordered properties and returns them in the appropriate order" do
    resource.authors = ["a", "b", "a"]
    output = persister.save(resource: resource)

    expect(output.authors).to eq ["a", "b", "a"]
  end
end
