# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class DynamicKlass
    def self.new(orm_object)
      orm_object.internal_model.first.constantize.new(cast_attributes(orm_object).merge(member_ids: orm_object.ordered_member_ids.map { |x| Valkyrie::ID.new(x) }))
    end

    def self.cast_attributes(orm_object)
      Hash[
        orm_object.attributes.map do |k, v|
          [k.to_sym, FedoraMapper.for(v).result]
        end
      ]
    end

    class FedoraMapper < ValueMapper
    end

    class ActiveTriplesRelationValue < ValueMapper
      FedoraMapper.register(self)
      def self.handles?(value)
        value.is_a?(ActiveTriples::Relation)
      end

      def result
        value.rel_args = { cast: false }
        calling_mapper.for(value.to_a).result
      end
    end

    class EnumerableValue < ValueMapper
      FedoraMapper.register(self)

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
      FedoraMapper.register(self)

      def self.handles?(value)
        value.is_a?(::RDF::URI) && !ActiveFedora::Base.uri_to_id(value).start_with?("http")
      end

      def result
        Valkyrie::ID.new(ActiveFedora::Base.uri_to_id(value))
      end
    end
  end
end
