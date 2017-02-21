# frozen_string_literal: true
class QueryService
  class_attribute :adapter
  # self.adapter = Valkyrie::Persistence::Postgres
  self.adapter = Valkyrie::Persistence::Fedora
  class << self
    delegate :find_all, :find_by_id, :find_members, to: :default_adapter

    def default_adapter
      new(adapter: adapter)
    end
  end

  attr_reader :adapter
  def initialize(adapter:)
    @adapter = adapter
  end

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
