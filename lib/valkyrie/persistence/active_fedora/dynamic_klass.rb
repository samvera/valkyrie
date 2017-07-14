# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora
  # A factory for Valkrie::Models given data from an ActiveFedora::Base
  # Because we override `new`, no instances of DynamicKlass are actually created.
  class DynamicKlass
    # Instantiate the appropriate subclass of Valkrie::Model given the data from
    # the `internal_model` field on the Valkyrie::Persistence::ActiveFedora::ORM::Resource class
    # @param [Valkyrie::Persistence::ActiveFedora::ORM::Resource]
    # @return [Valkrie::Model]
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
        "created_at" => orm_object.try(:create_date),
        "updated_at" => orm_object.try(:modified_date),
        "internal_model" => Array(orm_object.internal_model).first
      )
    end

    class ActiveFedoraMapper < ::Valkyrie::ValueMapper
    end

    class NestedResourceValue < ::Valkyrie::ValueMapper
      ActiveFedoraMapper.register(self)
      def self.handles?(value)
        value.is_a?(ActiveTriples::Relation) && value.first.is_a?(ActiveTriples::Resource) && !value.first.empty?
      end

      def result
        value.map do |value|
          DynamicKlass.cast_attributes(value)
        end
      end
    end

    class ActiveTriplesRelationValue < ::Valkyrie::ValueMapper
      ActiveFedoraMapper.register(self)
      def self.handles?(value)
        value.is_a?(ActiveTriples::Relation)
      end

      def result
        value.rel_args = { cast: false }
        calling_mapper.for(value.to_a).result
      end
    end

    class EnumerableValue < ::Valkyrie::ValueMapper
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

    class LocalIDValue < ::Valkyrie::ValueMapper
      ActiveFedoraMapper.register(self)

      def self.handles?(value)
        value.is_a?(::RDF::URI) && !ActiveFedora::Base.uri_to_id(value).start_with?("http")
      end

      def result
        Valkyrie::ID.new(ActiveFedora::Base.uri_to_id(value))
      end
    end

    class ExternalIDValue < ::Valkyrie::ValueMapper
      ActiveFedoraMapper.register(self)

      def self.handles?(value)
        value.is_a?(::RDF::Literal) && value.datatype == RDF::URI("http://example.com/valkyrie_id")
      end

      def result
        Valkyrie::ID.new(value.to_s)
      end
    end

    class DateTimeValue < ::Valkyrie::ValueMapper
      ActiveFedoraMapper.register(self)

      def self.handles?(value)
        value.is_a?(Time) || value.is_a?(DateTime)
      end

      def result
        value.is_a?(DateTime) ? value.utc : value.to_datetime.utc
      end
    end
  end
end
