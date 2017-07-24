# frozen_string_literal: true
class ChangeSetPersister
  attr_reader :metadata_adapter, :storage_adapter
  delegate :persister, :query_service, to: :metadata_adapter
  def initialize(metadata_adapter:, storage_adapter:)
    @metadata_adapter = metadata_adapter
    @storage_adapter = storage_adapter
  end

  def save(change_set:)
    before_save(change_set: change_set)
    persister.save(resource: change_set.resource).tap do |output|
      after_save(change_set: change_set, updated_resource: output)
    end
  end

  def delete(change_set:)
    before_delete(change_set: change_set)
    persister.delete(resource: change_set.resource)
  end

  def save_all(change_sets:)
    change_sets.map do |change_set|
      save(change_set: change_set)
    end
  end

  private

    def before_save(change_set:)
      create_files(change_set: change_set)
    end

    def after_save(change_set:, updated_resource:)
      append(append_id: change_set.append_id, updated_resource: updated_resource) if change_set.append_id
    end

    def append(append_id:, updated_resource:)
      parent_obj = query_service.find_by(id: append_id)
      parent_obj.member_ids = parent_obj.member_ids + [updated_resource.id]
      persister.save(resource: parent_obj)
    end

    def create_files(change_set:)
      appender = FileAppender.new(storage_adapter: storage_adapter, persister: persister, files: files(change_set: change_set))
      appender.append_to(change_set.resource)
    end

    def files(change_set:)
      change_set.try(:files) || []
    end

    def before_delete(change_set:)
      parents = query_service.find_parents(resource: change_set.resource)
      parents.each do |parent|
        parent.member_ids -= [change_set.id]
        persister.save(resource: parent)
      end
    end
end
