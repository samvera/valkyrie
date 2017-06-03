# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::ModelDecorator do
  let(:decorated_model) { described_class.new(book) }
  let(:book) { Book.new(title: "Testing") }

  it "delegates down" do
    expect(decorated_model.title).to eq book.title
  end
end
