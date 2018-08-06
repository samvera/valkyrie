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

  describe "#==" do
    subject(:token_a) { described_class.new(adapter_id: "adapter1", token: "token1") }

    context "two tokens have different adapters" do
      let(:token_b) { described_class.new(adapter_id: "adapter2", token: "token1") }

      it { is_expected.not_to eq(token_b) }
    end

    context "two tokens have the same adapters and different tokens" do
      let(:token_b) { described_class.new(adapter_id: "adapter1", token: "token2") }

      it { is_expected.not_to eq(token_b) }
    end

    context "two tokens have the same adapters and the same tokens" do
      let(:token_b) { described_class.new(adapter_id: "adapter1", token: "token1") }

      it { is_expected.to eq(token_b) }
    end

    context "when the other token is not a Valkyrie::Persistence::OptimisticLockToken" do
      let(:token_b) { "token1" }

      it { is_expected.not_to eq(token_b) }
    end
  end
end
