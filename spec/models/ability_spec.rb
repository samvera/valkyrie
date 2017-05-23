# frozen_string_literal: true
require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:public_book) { FactoryGirl.build(:book) }
  let(:user_owned_book) { FactoryGirl.build(:book, read_groups: [], read_users: current_user.user_key) }
  context "when logged in as a standard user" do
    it {
      is_expected.to be_able_to(:read, public_book)
      is_expected.to be_able_to(:read, user_owned_book)
    }
  end
  context "when not logged in" do
    let(:current_user) { nil }
    it {
      is_expected.to be_able_to(:read, public_book)
    }
  end
end
