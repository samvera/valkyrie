# frozen_string_literal: true
class Indexer
  attr_reader :repository
  def initialize(repository = NullPersister)
    @repository = repository
  end

  def save(obj)
    repository.save(obj).tap do |persisted_object|
      Persister.new(adapter: Valkyrie::Persistence::Solr).save(persisted_object)
    end
  end
end
