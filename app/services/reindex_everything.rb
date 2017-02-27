# frozen_string_literal: true
class ReindexEverything
  class << self
    def call
      persister = Persister.new(adapter: ::Valkyrie::Persistence::Solr)
      QueryService.find_all.each do |book|
        persister.save(book)
      end
    end
  end
end
