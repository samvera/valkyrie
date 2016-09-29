# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a good admin factory" do
    expect(FactoryGirl.build(:admin)).to be_valid
  end

  describe "#to_s" do
    it "returns the email" do
      expect(User.new(email: "test@test.com").to_s).to eq "test@test.com"
    end
  end
end
