# frozen_string_literal: true
class AppendingPersister
  attr_reader :persister
  delegate :adapter, :delete, to: :persister
  def initialize(persister)
    @persister = persister
  end

  def save(model)
    persister.save(model).tap do |result|
      append_model(result, model.try(:append_id))
    end
  end

  private

    def append_model(model, parent_id)
      return unless parent_id
      parent = query_service.find_by_id(id: parent_id)
      parent.member_ids = parent.member_ids + [model.id]
      persister.save(parent)
    end

    def query_service
      persister.adapter.query_service
    end
end
