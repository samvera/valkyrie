# frozen_string_literal: true
class FindAllQuery
  attr_reader :obj
  def initialize; end

  def run
    relation.lazy.map do |orm_book|
      member_klass.new(mapper.new(orm_book).attributes)
    end
  end

  private

    def relation
      orm_model.all
    end

    def member_klass
      Book
    end

    def orm_model
      ORM::Resource
    end

    def mapper
      ORMToObjectMapper
    end
end
