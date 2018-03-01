# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  # Acts as a null object representing the default case for paginating over solr
  # results. Often only used for the first iteration of a loop.
  class DefaultPaginator
    def next_page
      1
    end

    def per_page
      100
    end

    def has_next?
      true
    end
  end
end
