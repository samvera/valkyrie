# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::StorageAdapter::File' do
  before do
    raise 'adapter must be set with `let(:file)`' unless defined? file
  end

  subject { file }

  it { is_expected.to respond_to(:read) }
  it { is_expected.to respond_to(:rewind) }
  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:close) }
  describe "#disk_path" do
    it "returns an existing disk path" do
      expect(File.exist?(file.disk_path)).to eq true
    end
    it "can accept a block" do
      disk_path = nil
      file.disk_path do |f_path|
        expect(File.exist?(f_path)).to eq true
        disk_path = f_path
      end
      expect(disk_path).not_to be_nil
    end
  end
end
