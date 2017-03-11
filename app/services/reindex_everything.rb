# frozen_string_literal: true
class ReindexEverything
  class << self
    def call
      persister = Persister.new(adapter: ::Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection))
      QueryService.find_all.each do |book|
        persister.save(book)
      end
    end
  end
end
