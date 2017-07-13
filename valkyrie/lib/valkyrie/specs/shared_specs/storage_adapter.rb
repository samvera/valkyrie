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
    expect(uploaded_file = storage_adapter.upload(file: file, model: model)).to be_kind_of Valkyrie::StorageAdapter::File
    expect(storage_adapter.handles?(id: uploaded_file.id)).to eq true
    file = storage_adapter.find_by(id: uploaded_file.id)
    expect(file.id).to eq uploaded_file.id
    expect(file).to respond_to(:stream).with(0).arguments
    expect(file).to respond_to(:read).with(0).arguments
    expect(file).to respond_to(:rewind).with(0).arguments
    expect(file.stream).to respond_to(:read)
    new_file = Tempfile.new
    expect { IO.copy_stream(file, new_file) }.not_to raise_error
  end
end
