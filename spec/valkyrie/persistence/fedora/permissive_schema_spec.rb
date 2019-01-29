# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Fedora::PermissiveSchema do
  describe ".optimistic_lock_token" do
    it "returns the expected temporary URI" do
      expect(described_class.optimistic_lock_token).to eq RDF::URI("http://example.com/predicate/optimistic_lock_token")
    end
  end
end
