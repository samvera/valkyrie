# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::Queries
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
