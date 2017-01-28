# frozen_string_literal: true
class FindAllQuery
  attr_reader :obj
  def initialize; end

  def run
    relation.lazy.map do |orm_object|
      ResourceFactory.from_orm(orm_object)
    end
  end

  private

    def relation
      orm_model.all
    end

    def member_klass
      DynamicKlass
    end

    def orm_model
      ORM::Resource
    end
end
