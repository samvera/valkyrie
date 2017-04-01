# frozen_string_literal: true
class ParentCleanupPersister
  attr_reader :persister
  delegate :adapter, :save, to: :persister
  delegate :query_service, to: :adapter
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
end
