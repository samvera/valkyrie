class Indexer
  attr_reader :repository
  delegate :find, to: :repository
  def initialize(repository)
    @repository = repository
  end

  def save(obj)
    result = repository.save(obj)
    solr_document = Mapper.find(result).to_h
    solr_connection.add solr_document, params: { softCommit: true }
    result
  end

  private

    def solr_connection
      Blacklight.default_index.connection
    end
end
