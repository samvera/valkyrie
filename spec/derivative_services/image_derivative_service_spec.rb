# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe ImageDerivativeService do
  it_behaves_like "a Valkyrie::DerivativeService"

  let(:thumbnail) { Valkyrie::Vocab::PCDMUse.ThumbnailImage }
  let(:derivative_service) do
    ImageDerivativeService::Factory.new(form_persister: form_persister,
                                        use: [thumbnail])
  end
  let(:adapter) { Valkyrie::Adapter.find(:indexing_persister) }
  let(:storage_adapter) { Valkyrie.config.storage_adapter }
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
  let(:form_persister) { FormPersister.new(adapter: adapter, storage_adapter: storage_adapter) }
  let(:book) do
    form_persister.save(form: BookForm.new(Book.new, files: [file]))
  end
  let(:book_members) { query_service.find_members(model: book) }
  let(:valid_model) { book_members.first }
  let(:valid_form) { DynamicFormClass.new.new(valid_model) }

  it "creates a thumbnail and attaches it to the fileset" do
    derivative_service.new(valid_form).create_derivatives

    reloaded = query_service.find_by(id: valid_model.id)
    members = query_service.find_members(model: reloaded)
    derivative = members.find { |x| x.use.include?(Valkyrie::Vocab::PCDMUse.ServiceFile) }

    expect(derivative).to be_present
    derivative_file = Valkyrie::StorageAdapter.find_by(id: derivative.file_identifiers.first)
    image = MiniMagick::Image.open(derivative_file.io.path)
    expect(image.width).to eq 105
    expect(image.height).to eq 150
  end
end
