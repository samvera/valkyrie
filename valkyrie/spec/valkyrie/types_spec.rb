# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Types do
  before do
    class Resource < Valkyrie::Model
      attribute :title, Valkyrie::Types::SingleValuedString
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
end
