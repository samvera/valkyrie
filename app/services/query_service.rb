class QueryService
  class_attribute :adapter
  self.adapter = Valkyrie::Persistence::Postgres
  class << self

    def find_all
      build_query_class("FindAllQuery").new.run
    end

    def find_by_id(id)
      build_query_class("FindByIdQuery").new(id).run
    end

    def find_members(book)
      build_query_class("FindMembersQuery").new(book).run
    end

    def build_query_class(query_class_name)
      "#{adapter}::Queries::#{query_class_name}".constantize
    end
  end
end
