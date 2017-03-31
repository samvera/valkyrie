# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ReindexEverything do
  describe ".call" do
    let(:solr) { Blacklight.default_index.connection }
    context "when there are objects not indexed" do
      it "indexes them" do
        Persister.save(model: Book.new)
        expect(solr.get("select", params: { q: "*:*" })["response"]["numFound"]).to eq 0

        described_class.call

        expect(solr.get("select", params: { q: "*:*" })["response"]["numFound"]).to eq 1
      end
    end
  end
end
