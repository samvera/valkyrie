# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Song Management" do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user if user
  end
  describe "new" do
    context "when not logged in" do
      let(:user) { nil }
      it "throws a CanCan::AccessDenied error" do
        expect { get "/songs/new" }.to raise_error CanCan::AccessDenied
      end
    end
    it "has a form for creating songs" do
      Persister.save(resource: Collection.new(title: ["Test Collection"]))
      get "/songs/new"
      expect(response.body).to have_field "Title"
      expect(response.body).to have_button "Create Song"
      expect(response.body).to have_select 'A member of', options: ['', 'Test Collection']
    end
  end

  describe "create" do
    context "when not logged in" do
      let(:user) { nil }
      it "throws a CanCan::AccessDenied error" do
        expect { post "/songs", params: { song: { title: ["One", "Two"] } } }.to raise_error CanCan::AccessDenied
      end
    end
    it "can create a book with two titles" do
      post "/songs", params: { song: { title: ["One", "Two"] } }
      expect(response).to be_redirect
      expect(response.location).to start_with "http://www.example.com/catalog/"
      id = response.location.gsub("http://www.example.com/catalog/", "").gsub("%2F", "/").gsub(/^id-/, "")
      expect(find_book(id).title).to contain_exactly "One", "Two"
    end
    it "renders the form if it doesn't create a book" do
      post "/songs", params: { song: { test: ["1"] } }
      expect(response.body).to have_field "Title"
    end
    it "can create a book as a child of another" do
      post "/songs", params: { song: { title: ["One", "Two"] } }
      id = response.location.gsub("http://www.example.com/catalog/", "").gsub("%2F", "/").gsub(/^id-/, "")
      post "/songs", params: { song: { title: ["Child"], append_id: id } }
      parent_book = find_book(id)
      expect(parent_book.member_ids).not_to be_blank

      expect(request).to redirect_to parent_solr_document_path(parent_id: id, id: "id-#{parent_book.member_ids.first}")
    end
  end

  describe "destroy" do
    context "when not logged in" do
      let(:user) { nil }
      it "throws a CanCan::AccessDenied error" do
        book = Persister.save(resource: Book.new(title: "Test"))

        expect { delete song_path(id: book.id) }.to raise_error CanCan::AccessDenied
      end
    end
    it "can delete a book" do
      book = Persister.save(resource: Book.new(title: "Test"))
      delete song_path(id: book.id)

      expect(response).to redirect_to root_path
      expect { QueryService.find_by(id: book.id) }.to raise_error ::Valkyrie::Persistence::ObjectNotFoundError
    end
    it "cleans up associations in parents" do
      child = Persister.save(resource: Book.new)
      parent = Persister.save(resource: Book.new(member_ids: [child.id]))
      delete song_path(id: child.id)

      reloaded = QueryService.find_by(id: parent.id)
      expect(reloaded.member_ids).to eq []
    end
  end

  describe "#file_manager" do
    context "when not logged in" do
      let(:user) { nil }
      let(:book) { Persister.save(resource: Book.new(title: ["Testing"])) }
      it "throws a CanCan::AccessDenied error" do
        expect { get file_manager_song_path(id: book.id) }.to raise_error CanCan::AccessDenied
      end
    end
  end

  describe "edit" do
    context "when not logged in" do
      let(:user) { nil }
      let(:book) { Persister.save(resource: Book.new(title: ["Testing"])) }
      it "throws a CanCan::AccessDenied error" do
        expect { get edit_song_path(id: book.id) }.to raise_error CanCan::AccessDenied
      end
    end
    context "when a book doesn't exist" do
      it "raises an error" do
        expect { get edit_song_path(id: "test") }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
      end
    end
    context "when it does exist" do
      let(:book) { Persister.save(resource: Book.new(title: ["Testing"])) }
      it "renders a form" do
        get edit_song_path(id: book.id)
        expect(response.body).to have_field "Title", with: "Testing"
        expect(response.body).to have_button "Update Book"
      end
    end
  end

  describe "update" do
    context "when not logged in" do
      let(:user) { nil }
      let(:book) { Persister.save(resource: Book.new(title: ["Testing"])) }
      it "throws a CanCan::AccessDenied error" do
        expect { patch song_path(id: book.id), params: { song: { title: ["Two"] } } }.to raise_error CanCan::AccessDenied
      end
    end
    context "when a bookd oesn't exist" do
      it "raises an error" do
        expect { patch song_path(id: "test") }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
      end
    end
    context "when it does exist" do
      let(:song) { Persister.save(resource: Song.new(title: ["Testing"])) }
      let(:solr_adapter) { Valkyrie::MetadataAdapter.find(:index_solr) }
      it "saves it and redirects" do
        patch song_path(id: song.id), params: { song: { title: ["Two"] } }
        expect(response).to be_redirect
        expect(response.location).to eq solr_document_url(id: solr_adapter.resource_factory.from_resource(resource: song)[:id])
        get response.location
        expect(response.body).to have_content "Two"
      end
      it "renders the form if it fails validations" do
        patch song_path(id: song.id), params: { song: { title: [""] } }
        expect(response.body).to have_field "Title"
      end
    end
  end

  def find_book(id)
    QueryService.find_by(id: Valkyrie::ID.new(id.to_s))
  end
end
