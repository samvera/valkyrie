# frozen_string_literal: true
class FileSetAppendingPersister
  attr_reader :persister, :repository, :node_factory, :file_container_factory
  delegate :adapter, :delete, to: :persister
  def initialize(persister, repository:, node_factory:, file_container_factory:)
    @persister = persister
    @repository = repository
    @node_factory = node_factory
    @file_container_factory = file_container_factory
  end

  def save(model:)
    files(model).each do |file|
      file_node = persister.save(model: node_factory.new(label: file.original_filename))
      file_set = persister.save(model: file_container_factory.new(title: file.original_filename, member_ids: file_node.id))
      file_identifier = repository.upload(file: file, model: file_node)
      file_node.file_identifiers = file_set.file_identifiers + [file_identifier.id]
      persister.save(model: file_node)
      model.member_ids = model.member_ids + [file_set.id]
    end
    model.try(:sync)
    persister.save(model: model)
  end

  def files(model)
    model.try(:files) || []
  end
end
