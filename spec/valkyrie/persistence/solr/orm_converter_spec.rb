# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Solr::ORMConverter do
  subject(:converter) { described_class.new(solr_document, resource_factory: resource_factory) }
  let(:resource_factory) { instance_double(Valkyrie::Persistence::Solr::ResourceFactory, adapter_id: "test") }

  describe ".convert!" do
    before do
      class MyResource < Valkyrie::Resource
      end
    end
    after do
      Object.send(:remove_const, :MyResource)
    end
    context "when not given an updated_at key" do
      let(:solr_document) do
        {
          "id" => "test",
          "internal_resource_ssim" => ["MyResource"],
          "created_at_dtsi" => Time.current.utc.iso8601(6)
        }
      end
      it "is able to generate an object" do
        output = converter.convert!
        expect(output).to be_a MyResource
      end
    end
  end
end
