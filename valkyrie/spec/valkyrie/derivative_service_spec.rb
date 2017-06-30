# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::DerivativeService do
  it_behaves_like "a Valkyrie::DerivativeService"
  let(:valid_file_set) { FileSet.new }
  let(:derivative_service) { described_class }
  before do
    class FileSet < Valkyrie::Model
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title, Valkyrie::Types::Set
      attribute :file_identifiers, Valkyrie::Types::Set
      attribute :member_ids, Valkyrie::Types::Array
    end
  end
  after do
    Object.send(:remove_const, :FileSet)
  end

  it "can have a registered service" do
    new_service = instance_double(described_class, valid?: true)
    service_class = class_double(described_class, new: new_service)
    described_class.services << service_class
    expect(described_class.for(valid_file_set)).to eq new_service
  end
end
