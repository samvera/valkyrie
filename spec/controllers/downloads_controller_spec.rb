# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DownloadsController do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user if user
  end
  let(:persister) { Valkyrie.config.metadata_adapter.persister }
  let(:storage_adapter) { Valkyrie.config.storage_adapter }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

  describe "GET /downloads/:id" do
    context "when there's a FileNode with that ID" do
      let(:uploaded_file) { storage_adapter.upload(file: file, model: file_node) }
      let(:file_node) { persister.save(model: FileNode.new(mime_type: file.content_type, original_filename: file.original_filename)) }
      before do
        file_node.file_identifiers = uploaded_file.id
        persister.save(model: file_node)
      end
      it "returns it" do
        get :show, params: { id: file_node.id.to_s }

        uploaded_file.rewind

        expect(response.body).to eq uploaded_file.read
        headers = response.headers
        expect(headers['Content-Type']).to eq "image/tiff"
        expect(headers["Content-Disposition"]).to eq "inline; filename=\"example.tif\""
      end
    end
  end
end
