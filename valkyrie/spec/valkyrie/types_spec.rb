# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Types do
  before do
    class Resource < Valkyrie::Resource
      attribute :title, Valkyrie::Types::SingleValuedString
      attribute :authors, Valkyrie::Types::Array
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end

  describe "Single Valued String" do
    it "returns the first of a set of values" do
      resource = Resource.new(title: ["one", "two"])
      expect(resource.title).to eq "one"
    end
  end

  describe 'The array type' do
    it 'is not modifiable' do
      # We don't want to modify the defaults in the schema.
      expect { Resource.new.authors << 'foo' }.to raise_error(RuntimeError, "can't modify frozen Array")
    end
  end
end
