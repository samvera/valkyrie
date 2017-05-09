# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FileSetsController do
  let(:persister) { Valkyrie.config.adapter.persister }
  let(:query_service) { Valkyrie.config.adapter.query_service }
  describe "PATCH /file_sets/id" do
    it "can update a file set" do
      file_set = persister.save(model: FileSet.new(title: ["First"]))
      patch :update, params: { id: file_set.id.to_s, file_set: { title: ["Second"] } }

      file_set = query_service.find_by(id: file_set.id)
      expect(file_set.title).to eq ["Second"]
    end
  end
end
