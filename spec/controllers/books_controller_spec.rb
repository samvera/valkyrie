# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BooksController do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user if user
  end
  describe "GET /books/new" do
    it "renders a form with a new book" do
      get :new

      expect(response).to be_success
    end
  end

  describe "POST /books" do
    let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
    it "can upload a file" do
      post :create, params: { book: { title: ["Test"], files: [file] } }

      id = response.location.gsub("http://test.host/catalog/", "").gsub("%2F", "/").gsub(/^id-/, "")
      query_service = Valkyrie.config.adapter.query_service
      book = query_service.find_by(id: Valkyrie::ID.new(id))
      expect(book.member_ids).not_to be_blank
      file_set = query_service.find_members(model: book).first
      files = query_service.find_members(model: file_set)
      file = files.find { |x| x.use.include?(Valkyrie::Vocab::PCDMUse.OriginalFile) }

      expect(file.file_identifiers).not_to be_empty
      expect(file.label).to contain_exactly "example.tif"
      expect(file.original_filename).to contain_exactly "example.tif"
      expect(file.mime_type).to contain_exactly "image/tiff"
      expect(file.use).to contain_exactly Valkyrie::Vocab::PCDMUse.OriginalFile

      # Generate derivatives
      derivative = files.find { |x| x.use.include?(Valkyrie::Vocab::PCDMUse.ServiceFile) }
      expect(derivative).to be_present
      expect(derivative.use).to include Valkyrie::Vocab::PCDMUse.ThumbnailImage
    end
  end

  describe "GET /books/:id/append/book" do
    context "when not signed in" do
      let(:user) { nil }
      it "raises CanCan::AccessDenied" do
        parent = Persister.save(model: Book.new)
        expect { get :append, params: { id: parent.id, model: Book } }.to raise_error CanCan::AccessDenied
      end
    end
    it "renders a form to append a child book" do
      parent = Persister.save(model: Book.new)
      get :append, params: { id: parent.id, model: Book }

      expect(assigns(:form).append_id).to eq parent.id
    end
  end

  describe "PUT /books" do
    it "can set member IDs" do
      resource = Persister.save(model: Book.new(title: "Test"))
      child = Persister.save(model: Book.new)
      put :update, params: { book: { member_ids: [child.id.to_s] }, id: resource.id }

      expect(response).to be_redirect
      reloaded = QueryService.find_by(id: resource.id)
      expect(QueryService.find_members(model: reloaded)).not_to be_blank
    end
  end

  describe "GET /books/:id/append/page" do
    it "renders a form to append a child page" do
      parent = Persister.save(model: Page.new)
      get :append, params: { id: parent.id, model: Page }

      expect(assigns(:form).class).to eq PageForm
      expect(assigns(:form).append_id).to eq parent.id
    end
  end

  describe "GET /books/:id/file_manager" do
    it "sets the record and children variables" do
      child = Persister.save(model: Book.new)
      parent = Persister.save(model: Book.new(member_ids: child.id))

      get :file_manager, params: { id: parent.id }

      expect(assigns(:record).id).to eq parent.id
      expect(assigns(:children).map(&:id)).to eq [child.id]
    end
  end
end
