# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Solr::Mapper do
  subject(:mapper) { described_class.new(resource) }
  before do
    class Resource < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title, Valkyrie::Types::Set
      attribute :author, Valkyrie::Types::Set
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  let(:resource) do
    instance_double(Resource,
                    id: "1",
                    attributes:
                    {
                      created_at: Time.at(0),
                      title: ["Test", RDF::Literal.new("French", language: :fr)],
                      author: ["Author"]
                    })
  end

  describe "#to_h" do
    it "maps all available properties to the solr record" do
      expect(mapper.to_h).to eq(
        id: "id-#{resource.id}",
        title_ssim: ["Test", "French"],
        title_tesim: ["Test", "French"],
        title_tsim: ["Test", "French"],
        title_lang_ssim: ["eng", "fr"],
        title_lang_tesim: ["eng", "fr"],
        title_lang_tsim: ["eng", "fr"],
        author_ssim: ["Author"],
        author_tesim: ["Author"],
        author_tsim: ["Author"],
        created_at_dtsi: Time.at(0).utc.iso8601
      )
    end
  end
end
