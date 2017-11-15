# frozen_string_literal: true

RSpec.shared_examples 'a Valkyrie::FileCharacterizationService' do
  before do
    raise 'valid_file_node must be set with `let(:valid_file_node)`' unless
      defined? valid_file_node
    raise 'persister must be set with `let(:persister)`' unless
      defined? persister
    raise 'file_characterization_service must be set with `let(:file_characterization_service)`' unless
      defined? file_characterization_service
  end

  let(:file_node) { valid_file_node }
  subject { file_characterization_service.new(file_node: file_node, persister: persister) }

  it { is_expected.to respond_to(:characterize).with(0).arguments }
  it 'returns a file node' do
    expect(subject.characterize).to be_a(FileNode)
  end

  describe '#valid?' do
    context 'when given a file_node it handles' do
      let(:file_node) { valid_file_node }
      it { is_expected.to be_valid }
    end
  end

  it 'takes a file_node and a persister as arguments' do
    obj = file_characterization_service.new(file_node: file_node, persister: persister)
    expect(obj.file_node).to eq valid_file_node
    expect(obj.persister).to eq persister
  end
end
