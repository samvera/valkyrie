# frozen_string_literal: true
class ReindexEverything
  class << self
    def call
      persister = Valkyrie::Adapter.find(:index_solr).persister
      QueryService.find_all.each do |book|
        persister.save(model: book)
      end
    end
  end
end
