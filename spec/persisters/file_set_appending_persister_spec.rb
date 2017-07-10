# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe FileSetAppendingPersister do
  let(:persister) do
    described_class.new(
      Valkyrie::Persistence::Memory::Adapter.new.persister,
      storage_adapter: Valkyrie::StorageAdapter::Memory.new,
      node_factory: FileNode,
      file_container_factory: File
    )
  end
  it_behaves_like "a Valkyrie::Persister"
end
