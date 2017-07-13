# frozen_string_literal: true
##
# The {IndexingAdapter} enables a choice between indexing into another
# persister concurrently (via `#save`), or by doing a series of actions with the
# primary persister, tracking those actions, and then persisting them all into
# the `index_adapter` via a large `save_all` call. This is particularly
# efficient when the `index_adapter` is significantly faster for `save_all`
# than individual `saves` (such as with Solr).
class IndexingAdapter
  attr_reader :adapter, :index_adapter
  # @param adapter [Valkyrie::Persistence::Adapter]
  # @param index_adapter [Valkyrie::Persistence::Adapter]
  def initialize(adapter:, index_adapter:)
    @adapter = adapter
    @index_adapter = index_adapter
  end

  def persister
    IndexingAdapter::Persister.new(adapter: self)
  end

  delegate :query_service, to: :adapter

  class Persister
    attr_reader :adapter
    delegate :index_adapter, to: :adapter
    delegate :persister, to: :primary_adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def primary_adapter
      adapter.adapter
    end

    def index_persister
      index_adapter.persister
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    # @note This saves into both the `persister` and `index_persister`
    #   concurrently.
    def save(model:)
      composite_persister.save(model: model)
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    # @note This saves into both the `persister` and `index_persister`
    #   concurrently.
    def save_all(models:)
      composite_persister.save_all(models: models)
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    # @note This deletes from both the `persister` and `index_persister`
    #   concurrently.
    def delete(model:)
      composite_persister.delete(model: model)
    end

    # Yields the primary persister. At the end of the block, this will use changes tracked
    # by an in-memory persister to replicate new and deleted objects into the
    # `index_persister` in bulk.
    #
    # @example Creating two items
    #   indexing_persister.buffer_into_index do |persister|
    #     persister.save(model: Book.new)
    #     persister.save(model: Book.new)
    #     solr_index.query_service.find_all # => []
    #     persister.query_service.find_all # => [book1, book2]
    #   end
    #   solr_index.query_service.find_all # => [book1, book2]
    def buffer_into_index
      buffered_persister.with_buffer do |persist, buffer|
        yield Valkyrie::AdapterContainer.new(persister: persist, query_service: adapter.query_service)
        buffer.persister.deletes.uniq(&:id).each do |delete|
          index_persister.delete(model: delete)
        end
        index_persister.save_all(models: buffer.query_service.find_all)
      end
    end

    def composite_persister
      @composite_persister ||= Valkyrie::Persistence::CompositePersister.new(persister, index_persister)
    end

    def buffered_persister
      @buffered_persister ||= Valkyrie::Persistence::BufferedPersister.new(persister)
    end
  end
end
