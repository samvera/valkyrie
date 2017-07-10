# frozen_string_literal: true
class ParentCleanupPersister
  delegate :adapter, to: :persister
  def initialize(persister)
    @persister = persister
  end

  def delete(model:)
    parents = query_service.find_parents(model: model).to_a
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

  # (see Valkyrie::Persistence::Memory::Persister#save_all)
  def save_all(models:)
    models.map do |model|
      save(model: model)
    end
  end

  private

    attr_reader :persister
    private(*delegate(:query_service, to: :adapter))
end
