# frozen_string_literal: true

require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::FileCharacterizationService do
  it_behaves_like 'a Valkyrie::FileCharacterizationService'
  let(:valid_file_node) { FileNode.new }
  let(:file_characterization_service) { described_class }
  let(:persister) { Valkyrie::Persistence::Memory::MetadataAdapter.new.persister }
  before do
    class FileNode < Valkyrie::Model
      attribute :id, Valkyrie::Types::ID.optional
      attribute :mime_type, Valkyrie::Types::Set
      attribute :height, Valkyrie::Types::Set
      attribute :width, Valkyrie::Types::Set
      attribute :checksum, Valkyrie::Types::Set
    end
  end
  after do
    Object.send(:remove_const, :FileNode)
  end

  it 'can have a registered service' do
    new_service = instance_double(described_class, valid?: true)
    service_class = class_double(described_class, new: new_service)
    described_class.services << service_class
    expect(described_class.for(file_node: valid_file_node, persister: persister)).to eq new_service
  end
end
