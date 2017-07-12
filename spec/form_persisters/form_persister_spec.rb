# frozen_string_literal: true
require 'rails_helper'
require 'specs/shared_specs/form_persister'
include ActionDispatch::TestProcess

RSpec.describe FormPersister do
  subject(:form_persister) { described_class.new(adapter: adapter, storage_adapter: storage_adapter) }
  let(:adapter) { Valkyrie.config.adapter }
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }
  let(:storage_adapter) { Valkyrie.config.storage_adapter }
  let(:form_class) { BookForm }
  it_behaves_like "a FormPersister"
  describe "#save" do
    let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
    it "can handle appending to another record" do
      parent_book = persister.save(model: Book.new)
      form = form_class.new(Book.new)
      form.append_id = parent_book.id

      output = form_persister.save(form: form)
      reloaded_parent = query_service.find_by(id: parent_book.id)

      expect(reloaded_parent.member_ids).to eq [output.id]
    end

    it "can append files" do
      form = form_class.new(Book.new)
      form.files = [file]

      output = form_persister.save(form: form)
      members = query_service.find_members(model: output)

      expect(members.length).to eq 1
      expect(members[0]).to be_kind_of FileSet
    end
  end

  describe "#delete" do
    it "cleans up parent associations" do
      book = persister.save(model: Book.new)
      parent = persister.save(model: Book.new(member_ids: [book.id]))
      form = form_class.new(book)

      form_persister.delete(form: form)
      reloaded_parent = query_service.find_by(id: parent.id)

      expect(reloaded_parent.member_ids).to be_empty
    end
  end
end
