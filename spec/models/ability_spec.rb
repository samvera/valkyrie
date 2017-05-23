# frozen_string_literal: true
require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:public_book) { FactoryGirl.build(:book) }
  let(:user_owned_book) { FactoryGirl.build(:book, read_groups: [], read_users: current_user.user_key) }
  let(:user_editable_book) { FactoryGirl.build(:book, read_groups: [], edit_users: current_user.user_key) }
  context "when logged in as a standard user" do
    it {
      is_expected.to be_able_to(:read, public_book)
      is_expected.to be_able_to(:read, user_owned_book)
      is_expected.to be_able_to(:read, user_editable_book)

      is_expected.to be_able_to(:edit, user_editable_book)
      is_expected.to be_able_to(:file_manager, user_editable_book)

      is_expected.not_to be_able_to(:create, public_book.class)
    }
  end
  context "when logged in as an admin" do
    let(:current_user) { FactoryGirl.create(:admin) }
    it {
      is_expected.to be_able_to(:read, public_book)
      is_expected.to be_able_to(:read, user_owned_book)
      is_expected.to be_able_to(:read, user_editable_book)

      is_expected.to be_able_to(:edit, public_book)
      is_expected.to be_able_to(:edit, user_owned_book)
      is_expected.to be_able_to(:edit, user_editable_book)
    }
  end
  context "when not logged in" do
    let(:current_user) { nil }
    it {
      is_expected.to be_able_to(:read, public_book)
    }
  end
end
