# frozen_string_literal: true
require 'spec_helper'

# A Hash-typed attribute holding an array of one-key entry hashes must survive a
# save/reload with each entry intact. On the way out of Postgres, JSONValueMapper
# unwraps a one-key Hash to its [key, value] pair (a Hash responds to #each), so
# [{ name: 'a' }, { role: 'b' }] would otherwise come back flattened. Keys are
# symbolized on read, matching how multi-key (nested) hashes already round-trip.
RSpec.describe Valkyrie::Persistence::Postgres::Persister do
  let(:adapter) { Valkyrie::Persistence::Postgres::MetadataAdapter.new }
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }

  before do
    class HashEntryResource < Valkyrie::Resource
      attribute :entries, Valkyrie::Types::Array.of(Valkyrie::Types::Anything)
    end
  end
  after { Object.send(:remove_const, :HashEntryResource) }

  it 'keeps several one-key entry hashes as separate hashes' do
    saved = persister.save(resource: HashEntryResource.new(entries: [{ 'name' => 'Ada' }, { 'role' => 'Editor' }]))
    reloaded = query_service.find_by(id: saved.id)
    expect(reloaded.entries).to eq([{ name: 'Ada' }, { role: 'Editor' }])
  end

  it 'keeps a single one-key entry hash as a hash' do
    saved = persister.save(resource: HashEntryResource.new(entries: [{ 'value' => 'doi:10.0/abc' }]))
    reloaded = query_service.find_by(id: saved.id)
    expect(reloaded.entries).to eq([{ value: 'doi:10.0/abc' }])
  end

  it 'leaves a multi-key entry hash intact (regression guard)' do
    saved = persister.save(resource: HashEntryResource.new(entries: [{ 'name' => 'Ada', 'role' => 'Author' }]))
    reloaded = query_service.find_by(id: saved.id)
    expect(reloaded.entries).to eq([{ name: 'Ada', role: 'Author' }])
  end
end
