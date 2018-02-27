# frozen_string_literal: true
module Valkyrie::Persistence
  # Wraps up multiple persisters under a common interface, to transparently
  # persist to multiple places at once.
  #
  # @example
  #   persister = Valkyrie.config.metadata_adapter
  #   index_persister = Valkyrie::MetadataAdapter.find(:index_solr)
  #   Valkyrie::MetadataAdapter.register(
  #     Valkyrie::Persistence::CompositePersister.new(persister, index_persister),
  #     :my_composite_persister
  #   )
  #
  class CompositePersister
    attr_reader :persisters
    def initialize(*persisters)
      @persisters = persisters
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(resource:)
      persisters.inject(resource) { |m, persister| persister.save(resource: m) }
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(resources:)
      resources.map do |resource|
        save(resource: resource)
      end
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(resource:)
      persisters.inject(resource) { |m, persister| persister.delete(resource: m) }
    end

    def wipe!
      persisters.each_entry(&:wipe!)
    end
  end
end
