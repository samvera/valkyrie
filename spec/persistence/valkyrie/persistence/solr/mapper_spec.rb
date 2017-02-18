# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::Persistence::Solr::Mapper do
  subject { described_class.new(resource) }
  let(:resource) { instance_double(Book, id: "1", title: ["Test"], author: ["Author"], class: resource_class) }
  let(:resource_class) { class_double(Book, attribute_set: [object_double(obj_double, name: :id), object_double(obj_double, name: :title), object_double(obj_double, name: :author)]) }
  let(:obj_double) { Book.attribute_set.first }

  describe "#to_h" do
    it "maps all available properties to the solr record" do
      expect(subject.to_h).to eq(
        id: resource.id,
        title_ssim: ["Test"],
        title_tesim: ["Test"],
        author_ssim: ["Author"],
        author_tesim: ["Author"]
      )
    end
  end
end
