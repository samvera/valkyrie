# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::ID do
  subject(:id) { described_class.new("test") }

  describe "#to_uri" do
    context "when given a plain ID" do
      before do
        ENV['FCREPO_TEST_PORT'] = '8988'
      end

      after do
        ENV.delete('FCREPO_TEST_PORT')
      end

      it "delegates down to AF" do
        expect(id.to_uri).to eq RDF::URI("http://localhost:8988/rest/test/test")
      end
    end
    context "when given an external ID protocol" do
      subject(:id) { described_class.new("memory://test") }
      it "returns it as an RDF literal with a datatype" do
        uri = id.to_uri

        expect(uri.to_s).to eq "memory://test"
        expect(uri.datatype).to eq RDF::URI("http://example.com/valkyrie_id")
      end
    end
  end
end
