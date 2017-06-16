# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora
  class DynamicKlass
    def self.new(orm_object)
      orm_object.internal_model.constantize.new(cast_attributes(orm_object).merge(member_ids: orm_object.ordered_member_ids.map { |x| Valkyrie::ID.new(x) }))
    end

    def self.cast_attributes(orm_object)
      Hash[
        attributes(orm_object).map do |k, v|
          [k.to_sym, ActiveFedoraMapper.for(v).result]
        end
      ]
    end

    def self.attributes(orm_object)
      orm_object.attributes.merge(
        "read_groups" => orm_object.read_groups,
        "read_users" => orm_object.read_users,
        "edit_users" => orm_object.edit_users,
        "edit_groups" => orm_object.edit_groups,
        "internal_model" => Array(orm_object.internal_model).first,
        "created_at" => orm_object.create_date,
        "updated_at" => orm_object.modified_date
      )
    end

    class ActiveFedoraMapper < ValueMapper
    end

    class ActiveTriplesRelationValue < ValueMapper
      ActiveFedoraMapper.register(self)
      def self.handles?(value)
        value.is_a?(ActiveTriples::Relation)
      end

      def result
        value.rel_args = { cast: false }
        calling_mapper.for(value.to_a).result
      end
    end

    class EnumerableValue < ValueMapper
      ActiveFedoraMapper.register(self)

      def self.handles?(value)
        value.respond_to?(:each)
      end

      def result
        value.map do |val|
          calling_mapper.for(val).result
        end
      end
    end

    class LocalIDValue < ValueMapper
      ActiveFedoraMapper.register(self)

      def self.handles?(value)
        value.is_a?(::RDF::URI) && !ActiveFedora::Base.uri_to_id(value).start_with?("http")
      end

      def result
        Valkyrie::ID.new(ActiveFedora::Base.uri_to_id(value))
      end
    end

    class ExternalIDValue < ValueMapper
      ActiveFedoraMapper.register(self)

      def self.handles?(value)
        value.is_a?(::RDF::Literal) && value.datatype == RDF::URI("http://example.com/valkyrie_id")
      end

      def result
        Valkyrie::ID.new(value.to_s)
      end
    end
  end
end
