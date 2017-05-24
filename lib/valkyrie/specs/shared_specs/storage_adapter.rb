# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::StorageAdapter' do
  before do
    raise 'storage_adapter must be set with `let(:storage_adapter)`' unless
      defined? storage_adapter
    raise 'file must be set with `let(:file)`' unless
      defined? file
    class CustomResource < Valkyrie::Model
      attribute :id, Valkyrie::Types::ID.optional
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end
  subject { storage_adapter }
  it { is_expected.to respond_to(:handles?).with_keywords(:id) }
  it { is_expected.to respond_to(:find_by).with_keywords(:id) }
  it { is_expected.to respond_to(:upload).with_keywords(:file, :model) }

  it "can upload and re-fetch a file" do
    model = CustomResource.new(id: "test")
    uploaded_file = storage_adapter.upload(file: file, model: model)

    expect(storage_adapter.handles?(id: uploaded_file.id)).to eq true
    expect(storage_adapter.find_by(id: uploaded_file.id).id).to eq uploaded_file.id
  end
end
