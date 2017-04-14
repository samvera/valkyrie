# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class DynamicKlass
    def self.new(orm_object)
      orm_object.internal_model.first.constantize.new(cast_attributes(orm_object).merge("member_ids" => orm_object.ordered_member_ids.map { |x| Valkyrie::ID.new(x) }))
    end

    def self.cast_attributes(orm_object)
      Hash[
        orm_object.attributes.map do |k, v|
          [k, Value.for(v).result]
        end
      ]
    end

    class Value
      class_attribute :value_processors
      self.value_processors = []
      class << self
        def register(klass)
          value_processors << klass
        end

        def for(value)
          (value_processors + [Value]).find do |value_processor|
            value_processor.handles?(value)
          end.new(value)
        end

        def handles?(_value)
          true
        end
      end

      attr_reader :value
      def initialize(value)
        @value = value
      end

      def result
        value
      end
    end

    class ActiveTriplesRelationValue < Value
      Value.register(self)
      def self.handles?(value)
        value.is_a?(ActiveTriples::Relation)
      end

      def result
        value.rel_args = { cast: false }
        Value.for(value.to_a).result
      end
    end

    class EnumerableValue < Value
      Value.register(self)

      def self.handles?(value)
        value.respond_to?(:each)
      end

      def result
        value.map do |val|
          Value.for(val).result
        end
      end
    end

    class LocalIDValue < Value
      Value.register(self)

      def self.handles?(value)
        value.is_a?(::RDF::URI) && !ActiveFedora::Base.uri_to_id(value).start_with?("http")
      end

      def result
        Valkyrie::ID.new(ActiveFedora::Base.uri_to_id(value))
      end
    end
  end
end
