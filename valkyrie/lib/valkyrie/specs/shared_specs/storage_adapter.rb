# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::StorageAdapter' do
  before do
    raise 'storage_adapter must be set with `let(:storage_adapter)`' unless
      defined? storage_adapter
    raise 'file must be set with `let(:file)`' unless
      defined? file
    raise 'version2 must be set with `let(:version2)`' unless
      defined? version2
    class CustomResource < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
  end
  subject { storage_adapter }
  it { is_expected.to respond_to(:handles?).with_keywords(:id) }
  it { is_expected.to respond_to(:find_by).with_keywords(:id) }
  it { is_expected.to respond_to(:delete).with_keywords(:id) }
  it { is_expected.to respond_to(:upload).with_keywords(:file, :resource, :original_filename) }

  it "can upload, validate, re-fetch, and delete a file" do
    resource = CustomResource.new(id: "test")
    sha1 = Digest::SHA1.file(file).to_s
    size = file.size
    expect(uploaded_file = storage_adapter.upload(file: file, original_filename: 'foo.jpg', resource: resource)).to be_kind_of Valkyrie::StorageAdapter::File

    expect(uploaded_file).to respond_to(:checksum).with_keywords(:digests)
    expect(uploaded_file).to respond_to(:valid?).with_keywords(:size, :digests)
    expect(uploaded_file.checksum(digests: [Digest::SHA1.new])).to eq([sha1])
    expect(uploaded_file.valid?(digests: { sha1: sha1 })).to be true
    expect(uploaded_file.valid?(size: size, digests: { sha1: sha1 })).to be true
    expect(uploaded_file.valid?(size: (size + 1), digests: { sha1: sha1 })).to be false
    expect(uploaded_file.valid?(size: size, digests: { sha1: 'bogus' })).to be false

    expect(storage_adapter.handles?(id: uploaded_file.id)).to eq true
    file = storage_adapter.find_by(id: uploaded_file.id)
    expect(file.id).to eq uploaded_file.id
    expect(file).to respond_to(:stream).with(0).arguments
    expect(file).to respond_to(:read).with(0).arguments
    expect(file).to respond_to(:rewind).with(0).arguments
    expect(file.stream).to respond_to(:read)
    new_file = Tempfile.new
    expect { IO.copy_stream(file, new_file) }.not_to raise_error

    storage_adapter.delete(id: uploaded_file.id)
    expect { storage_adapter.find_by(id: uploaded_file.id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    expect { storage_adapter.find_by(id: Valkyrie::ID.new("noexist")) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
  end

  it "can version files" do
    resource = CustomResource.new(id: "test")
    stored1 = storage_adapter.upload(file: file, original_filename: 'foo.jpg', resource: resource)
    expect(stored1).to be_kind_of Valkyrie::StorageAdapter::File

    stored2 = storage_adapter.upload(file: version2, original_filename: 'foo.jpg', resource: resource, previous: stored1)
    expect(stored2).to be_kind_of Valkyrie::StorageAdapter::File

    expect(stored1.read).not_to eq stored2.read
    file = storage_adapter.find_by(id: stored1.id)
    file = storage_adapter.find_by(id: stored2.id)

  end
end
