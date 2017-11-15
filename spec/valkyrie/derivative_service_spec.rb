# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::DerivativeService do
  it_behaves_like "a Valkyrie::DerivativeService"
  let(:valid_change_set) { FileSetChangeSet.new(FileSet.new) }
  let(:derivative_service) { described_class }
  before do
    class FileSet < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title, Valkyrie::Types::Set
      attribute :file_identifiers, Valkyrie::Types::Set
      attribute :member_ids, Valkyrie::Types::Array
    end

    class FileSetChangeSet < Valkyrie::ChangeSet
    end
  end
  after do
    Object.send(:remove_const, :FileSet)
    Object.send(:remove_const, :FileSetChangeSet)
  end

  it "can have a registered service" do
    new_service = instance_double(described_class, valid?: true)
    service_class = class_double(described_class, new: new_service)
    described_class.services << service_class
    expect(described_class.for(valid_change_set)).to eq new_service
  end
end
