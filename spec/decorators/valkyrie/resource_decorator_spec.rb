# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::ResourceDecorator do
  let(:decorated_resource) { described_class.new(book) }
  let(:book) { Book.new(title: "Testing") }

  it "delegates down" do
    expect(decorated_resource.title).to eq book.title
  end
end
