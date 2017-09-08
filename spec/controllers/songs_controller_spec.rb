# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SongsController, is_song: true do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user if user
  end
  describe "GET /songs/new" do
    it "renders a form with a new song" do
      get :new

      expect(response).to be_success
    end
  end

  describe "POST /songs" do
    let(:file) { fixture_file_upload('files/horse.mp3', 'audio/mp3') }

    it "can upload a file" do
      post :create, params: { song: { title: ["Test"], files: [file] } }

      id = response.location.gsub("http://test.host/catalog/", "").gsub("%2F", "/").gsub(/^id-/, "")
      query_service = Valkyrie.config.metadata_adapter.query_service
      song = query_service.find_by(id: Valkyrie::ID.new(id))
      expect(song.member_ids).not_to be_blank
      file_set = query_service.find_members(resource: song).first
      files = query_service.find_members(resource: file_set)
      file = files.find { |x| x.use.include?(Valkyrie::Vocab::PCDMUse.OriginalFile) }

      expect(file.file_identifiers).not_to be_empty
      expect(file.label).to contain_exactly "horse.mp3"
      expect(file.original_filename).to contain_exactly "horse.mp3"
      expect(file.mime_type).to contain_exactly "audio/mp3"
      expect(file.use).to contain_exactly Valkyrie::Vocab::PCDMUse.OriginalFile

      # Does not Generate derivatives (for now)
      derivative = files.find { |x| x.use.include?(Valkyrie::Vocab::PCDMUse.ServiceFile) }
      expect(derivative).not_to be_present
    end
  end

  describe "PUT /songs" do
    it "can set member IDs" do
      resource = Persister.save(resource: Song.new(title: "Test"))
      put :update, params: { song: { title: "Test Put" }, id: resource.id }

      expect(response).to be_redirect
      reloaded = QueryService.find_by(id: resource.id)
      expect(reloaded.title).to eq(["Test Put"])
    end
  end

  describe "GET /songs/:id/file_manager" do
    it "sets the record and children variables" do
      child = Persister.save(resource: Song.new)
      parent = Persister.save(resource: Song.new(member_ids: child.id))

      get :file_manager, params: { id: parent.id }

      expect(assigns(:record).id).to eq parent.id
      expect(assigns(:children).map(&:id)).to eq [child.id]
    end
  end
end
