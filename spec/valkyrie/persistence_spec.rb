# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence do
  it "defines a constant for optimistic lock attribute" do
    expect(described_class::Attributes::OPTIMISTIC_LOCK).to eq :optimistic_lock_token
  end
end
