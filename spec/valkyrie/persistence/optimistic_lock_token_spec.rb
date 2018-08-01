# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::OptimisticLockToken do
  subject(:lock_token) { described_class.new(token: token, adapter_id: adapter_id) }
  let(:adapter_id) { Valkyrie::ID.new('adapter_id') }
  let(:token) { "tok:en" }

  describe "#initialize" do
    it "defines a token and an adapter_id" do
      expect(lock_token.token).to eq(token)
      expect(lock_token.adapter_id).to eq(adapter_id)
    end
  end

  describe "#serialize" do
    it "casts the object to a string" do
      expect(lock_token.serialize).to eq "lock_token:#{adapter_id}:#{token}"
    end
  end

  describe ".deserialize" do
    it "casts a string to an object" do
      deserialized_token = described_class.deserialize(lock_token.serialize)
      expect(deserialized_token.token).to eq token
      expect(deserialized_token.adapter_id).to eq adapter_id
      expect(deserialized_token.adapter_id).to be_a Valkyrie::ID
    end
  end
end
