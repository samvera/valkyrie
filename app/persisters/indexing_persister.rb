# frozen_string_literal: true
class IndexingPersister
  attr_reader :persister, :index_persister, :workflow_decorator
  delegate :adapter, to: :composite_persister
  def initialize(persister:, index_persister:, workflow_decorator: SimpleDelegator)
    @persister = persister
    @index_persister = index_persister
    @workflow_decorator = workflow_decorator
  end

  def save(model:)
    composite_persister.save(model: model)
  end

  def save_all(models:)
    composite_persister.save_all(models: models)
  end

  def delete(model:)
    composite_persister.delete(model: model)
  end

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
    @buffered_persister ||= Valkyrie::Persistence::BufferedPersister.new(persister, buffer_class: buffer_class)
  end

  def buffer_class
    DeleteTrackingBuffer
  end

  class DeleteTrackingBuffer < Valkyrie::Persistence::Memory::Adapter
    def persister
      @persister ||= DeleteTrackingBuffer::Persister.new(self)
    end

    class Persister < Valkyrie::Persistence::Memory::Persister
      attr_reader :deletes
      def initialize(*args)
        @deletes = []
        super
      end

      def delete(model:)
        @deletes << model
        super
      end
    end
  end
end
