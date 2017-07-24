# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CollectionsController do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user if user
  end
  describe "GET /collections/new" do
    it "renders a form with a new book" do
      get :new

      expect(response).to be_success
    end
  end

  describe "GET /collections/:id/edit" do
    it "renders a form with an existing book" do
      resource = Persister.save(resource: Collection.new(title: "One"))

      get :edit, params: { id: resource.id.to_s }

      expect(response).to be_success
    end
  end

  describe "POST /collections" do
    it "can create collections" do
      post :create, params: { collection: { title: ["Test"] } }

      id = response.location.gsub("http://test.host/catalog/", "").gsub("%2F", "/").gsub(/^id-/, "")
      query_service = Valkyrie.config.metadata_adapter.query_service
      collection = query_service.find_by(id: Valkyrie::ID.new(id))
      expect(collection.title).to eq ["Test"]
    end
  end

  describe "PATCH /collections" do
    it "can update collections" do
      resource = Persister.save(resource: Collection.new(title: "One"))
      patch :update, params: { collection: { title: "Two" }, id: resource.id }

      expect(response).to be_redirect
      reloaded = QueryService.find_by(id: resource.id)
      expect(reloaded.title).to eq ["Two"]
    end
  end
end
