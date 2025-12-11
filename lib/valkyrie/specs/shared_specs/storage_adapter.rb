# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::StorageAdapter' do
  before do
    raise 'storage_adapter must be set with `let(:storage_adapter)`' unless
      defined? storage_adapter
    raise 'file must be set with `let(:file)`' unless
      defined? file
    class Valkyrie::Specs::CustomResource < Valkyrie::Resource
    end
  end
  after do
    Valkyrie::Specs.send(:remove_const, :CustomResource)
  end
  subject { storage_adapter }
  it { is_expected.to respond_to(:protocol) }
  it { is_expected.to respond_to(:handles?).with_keywords(:id) }
  it { is_expected.to respond_to(:find_by).with_keywords(:id) }
  it { is_expected.to respond_to(:delete).with_keywords(:id) }
  it { is_expected.to respond_to(:upload).with_keywords(:file, :resource, :original_filename) }
  it { is_expected.to respond_to(:supports?) }

  it "returns false for non-existing features" do
    expect(storage_adapter.supports?(:bad_feature_not_real_dont_implement)).to eq false
  end

  it "can upload a file which is just an IO" do
    io_file = Tempfile.new('temp_io')
    io_file.write "Stuff"
    io_file.rewind
    sha1 = Digest::SHA1.file(io_file).to_s

    resource = Valkyrie::Specs::CustomResource.new(id: SecureRandom.uuid)

    expect(uploaded_file = storage_adapter.upload(file: io_file, original_filename: 'foo.jpg', resource: resource, fake_upload_argument: true)).to be_kind_of Valkyrie::StorageAdapter::File

    expect(uploaded_file.valid?(digests: { sha1: sha1 })).to be true
  end

  it "can upload a ::File" do
    # WebMock prevents the request from using send_request_with_body_stream as it can do IRL
    WebMock.disable!
    allow(storage_adapter).to receive(:file_mover).and_return(FileUtils.method(:cp))
    File.open(Valkyrie.root_path.join("spec", "fixtures", "files", "tn_example.jpg")) do |io_file|
      sha1 = Digest::SHA1.file(io_file).to_s

      resource = Valkyrie::Specs::CustomResource.new(id: SecureRandom.uuid)

      expect(uploaded_file = storage_adapter.upload(file: io_file, original_filename: 'foo.jpg', resource: resource, fake_upload_argument: true)).to be_kind_of Valkyrie::StorageAdapter::File

      expect(uploaded_file.valid?(digests: { sha1: sha1 })).to be true
    end
    WebMock.enable!
  end

  xit "doesn't leave a file handle open on upload/find_by" do
    # No file handle left open from upload.
    resource = Valkyrie::Specs::CustomResource.new(id: "testdiscovery")
    pre_open_files = open_files
    uploaded_file = storage_adapter.upload(file: file, original_filename: 'foo.jpg', resource: resource, fake_upload_argument: true)
    file.close
    expect(pre_open_files.size).to eq open_files.size

    # No file handle left open from find_by
    pre_open_files = open_files
    the_file = storage_adapter.find_by(id: uploaded_file.id)
    expect(the_file).to be_kind_of Valkyrie::StorageAdapter::File
    expect(pre_open_files.size).to be <= open_files.size
  end

  def open_files
    `lsof +D .`.split("\n").map { |r| r.split(/\s+/).last }
  end

  it "can upload, validate, re-fetch, and delete a file" do
    resource = Valkyrie::Specs::CustomResource.new(id: "test#{SecureRandom.uuid}")
    sha1 = Digest::SHA1.file(file).to_s
    size = file.size
    uploaded_file = storage_adapter.upload(file: file, original_filename: 'foo.jpg', resource: resource, fake_upload_argument: true)

    expect(uploaded_file).to be_kind_of Valkyrie::StorageAdapter::File
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

  it "can upload and find new versions" do
    pending "Versioning not supported" unless storage_adapter.supports?(:versions)
    resource = Valkyrie::Specs::CustomResource.new(id: "test#{SecureRandom.uuid}")
    uploaded_file = storage_adapter.upload(file: file, original_filename: 'foo.jpg', resource: resource, fake_upload_argument: true)
    expect(uploaded_file.version_id).not_to be_blank

    f = Tempfile.new
    f.puts "Test File"
    f.rewind

    # upload_version
    new_version = storage_adapter.upload_version(id: uploaded_file.id, file: f)
    expect(uploaded_file.id).to eq new_version.id
    expect(uploaded_file.version_id).not_to eq new_version.version_id

    # find_versions
    # Two versions of the same file have the same id, but different version_ids,
    # use case: I want to store metadata about a file when it's uploaded as a
    #   version and refer to it consistently.
    versions = storage_adapter.find_versions(id: new_version.id)
    expect(versions.length).to eq 2
    expect(versions.first.id).to eq new_version.id
    expect(versions.first.version_id).to eq new_version.version_id

    expect(versions.last.id).to eq uploaded_file.id
    expect(versions.last.version_id).to eq uploaded_file.version_id

    expect(versions.first.size).not_to eq versions.last.size

    expect(storage_adapter.find_by(id: uploaded_file.version_id).version_id).to eq uploaded_file.version_id

    # Deleting a version should leave the current versions
    if storage_adapter.supports?(:version_deletion)
      storage_adapter.delete(id: uploaded_file.version_id)
      remnants = storage_adapter.find_versions(id: uploaded_file.id)
      expect(remnants.length).to eq 1
      expect(remnants.first.version_id).to eq new_version.version_id
      expect { storage_adapter.find_by(id: uploaded_file.version_id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end
    current_length = storage_adapter.find_versions(id: new_version.id).length

    # Restoring a previous version is just pumping its file into upload_version
    newest_version = storage_adapter.upload_version(file: new_version, id: new_version.id)
    current_length += 1
    expect(newest_version.version_id).not_to eq new_version.id
    expect(storage_adapter.find_by(id: newest_version.id).version_id).to eq newest_version.version_id

    # I can restore a version twice
    newest_version = storage_adapter.upload_version(file: new_version, id: new_version.id)
    current_length += 1
    expect(newest_version.version_id).not_to eq new_version.id
    expect(storage_adapter.find_by(id: newest_version.id).version_id).to eq newest_version.version_id
    expect(storage_adapter.find_versions(id: newest_version.id).length).to eq current_length

    # Fedora 6.5 may not create versions when the timestamp is the same?
    # See: https://fedora-repository.atlassian.net/browse/FCREPO-3958
    sleep 1 if storage_adapter.supports?(:list_deleted_versions)

    # NOTE: We originally wanted deleting the current record to push it into the
    # versions history, but FCRepo 4/5/6 doesn't work that way, so we changed to
    # instead make deleting delete everything.
    storage_adapter.delete(id: new_version.id)
    expect { storage_adapter.find_by(id: new_version.id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound

    if storage_adapter.supports?(:list_deleted_versions)
      expect(storage_adapter.find_versions(id: new_version.id).length).to eq current_length
    else
      expect(storage_adapter.find_versions(id: new_version.id).length).to eq 0
    end

  ensure
    f&.close
  end
end
