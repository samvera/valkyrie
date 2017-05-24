# frozen_string_literal: true
class AppendingPersister
  attr_reader :persister
  delegate :adapter, to: :persister
  def initialize(persister)
    @persister = persister
  end

  def save(model:)
    persister.save(model: model).tap do |result|
      append_model(result, model.try(:append_id))
    end
  end

  def save_all(models:)
    persister.save_all(models: models).tap do |result|
      result.each do |model|
        append_model(result, model.try(:append_id))
      end
    end
  end

  def delete(model:)
    persister.delete(model: model)
  end

  private

    def append_model(model, parent_id)
      return unless parent_id
      parent = query_service.find_by(id: parent_id)
      parent.member_ids = parent.member_ids + [model.id]
      persister.save(model: parent)
    end

    def query_service
      persister.adapter.query_service
    end
end
