# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  # Acts as a null object representing the default case for paginating over solr
  # results. Often only used for the first iteration of a loop, or to retrieve
  # all Documents in an index.
  class Paginator
    attr_reader :per_page, :next_page, :has_next

    def initialize(start:, batch_size:)
      default = DefaultPaginator.new
      @per_page = batch_size || default.per_page
      @next_page = start || default.next_page
      @has_next = default.has_next?
    end

    alias has_next? has_next
  end
end
