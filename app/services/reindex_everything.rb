# frozen_string_literal: true
class ReindexEverything
  class << self
    def call
      persister = Penguin::Adapter.find(:index_solr).persister
      QueryService.find_all.each do |book|
        persister.save(book)
      end
    end
  end
end
