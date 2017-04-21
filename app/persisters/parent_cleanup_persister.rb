# frozen_string_literal: true
class ParentCleanupPersister
  delegate :adapter, to: :persister
  def initialize(persister)
    @persister = persister
  end

  def delete(model:)
    parents = query_service.find_parents(model: model)
    persister.delete(model: model)
    parents.each do |parent|
      parent.member_ids -= [model.id]
      persister.save(model: parent)
    end
    model
  end

  def save(model:)
    persister.save(model: model)
  end

  def save_all(models:)
    persister.save_all(models: models)
  end

  private

    attr_reader :persister
    private(*delegate(:query_service, to: :adapter))
end
