# frozen_string_literal: true
FactoryGirl.define do
  factory :admin, parent: :user do
    sequence(:email) { |_n| "email-#{srand}@test.com" }
    password 'a password'
    password_confirmation 'a password'
    after(:build) do |user|
      def user.groups
        ['admin']
      end
    end
  end
end
