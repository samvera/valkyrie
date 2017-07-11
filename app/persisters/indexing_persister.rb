# frozen_string_literal: true
##
# The {IndexingPersister} enables a choice between indexing into another
# persister concurrently (via `#save`), or by doing a series of actions with the
# primary persister, tracking those actions, and then persisting them all into
# the `index_persister` via a large `save_all` call. This is particularly
# efficient when the `index_persister` is significantly faster for `save_all`
# than individual `saves` (such as with Solr).
class IndexingPersister
  attr_reader :persister, :index_persister, :workflow_decorator
  delegate :adapter, to: :composite_persister
  # @param persister [Valkyrie::Persistence::Persister]
  # @param index_persister [Valkyrie::Persistence::Persister]
  # @param workflow_decorator [SimpleDelegator] Decorator for adding workflow
  #   actions during save (such as minting IDs, creating FileSets, etc)
  def initialize(persister:, index_persister:, workflow_decorator: SimpleDelegator)
    @persister = persister
    @index_persister = index_persister
    @workflow_decorator = workflow_decorator
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

  # Yields the primary persister which is decorated with the
  # `workflow_decorator.` At the end of the block, this will use changes tracked
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
      persist = workflow_decorator.new(persist)
      yield persist
      buffer.persister.deletes.uniq(&:id).each do |delete|
        index_persister.delete(model: delete)
      end
      index_persister.save_all(models: buffer.query_service.find_all)
    end
  end

  def composite_persister
    @composite_persister ||= Valkyrie::Persistence::CompositePersister.new(workflow_decorator.new(persister), index_persister)
  end

  def buffered_persister
    @buffered_persister ||= Valkyrie::Persistence::BufferedPersister.new(persister)
  end
end
