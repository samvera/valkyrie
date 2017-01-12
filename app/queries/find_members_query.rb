# frozen_string_literal: true
class FindMembersQuery
  attr_reader :obj
  def initialize(obj)
    @obj = obj
  end

  def run
    relation.lazy.map do |orm_book|
      member_klass.new(mapper.new(orm_book).attributes)
    end
  end

  private

    def relation
      orm_model.find_by_sql([query, obj.id])
    end

    def query
      <<-SQL
        SELECT member.* FROM orm_books a,
        jsonb_array_elements_text(a.metadata->'member_ids') WITH ORDINALITY AS b(member, member_pos)
        JOIN orm_books member ON b.member::uuid = member.id WHERE a.id = ?
        ORDER BY b.member_pos
      SQL
    end

    def member_klass
      Book
    end

    def orm_model
      ORM::Book
    end

    def mapper
      ORMToObjectMapper
    end
end
