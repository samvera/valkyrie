# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::Persistence::Solr::Mapper do
  subject(:mapper) { described_class.new(resource) }
  let(:resource) { instance_double(Book, id: "1", title: ["Test"], author: ["Author"], attributes: { title: nil, author: nil, id: nil }) }

  describe "#to_h" do
    it "maps all available properties to the solr record" do
      expect(mapper.to_h).to eq(
        id: "id-#{resource.id}",
        title_ssim: ["Test"],
        title_tesim: ["Test"],
        author_ssim: ["Author"],
        author_tesim: ["Author"]
      )
    end
  end
end
