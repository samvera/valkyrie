# frozen_string_literal: true
class ReindexEverything
  class << self
    def call
      persister = Indexer.new
      FindAllQuery.new.run.each do |book|
        persister.save(book)
      end
    end
  end
end
