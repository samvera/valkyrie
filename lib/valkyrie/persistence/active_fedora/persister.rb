# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora
  class Persister
    class << self
      delegate :save, :delete, to: :instance
      def save(model:)
        instance(model).save
      end

      def delete(model:)
        instance(model).delete
      end

      def adapter
        Valkyrie::Persistence::ActiveFedora::Adapter
      end

      def instance(model)
        new(model: model)
      end
    end

    attr_reader :model
    def initialize(model:)
      @model = model
    end

    def save
      orm_object.attributes = cast_attributes.except(:id, :member_ids)
      process_members if member_ids
      orm_object.save!
      @model = resource_factory.to_model(orm_object)
      model
    end

    def cast_attributes
      FedoraAttributes.new(model.attributes.except(:created_at, :updated_at)).result
    end

    def delete
      orm_object.delete
      orm_object
    end

    private

      def orm_object
        @orm_object ||= resource_factory.from_model(model)
      end

      def process_members
        member_predicate = orm_object.association(:members).reflection.options[:has_member_relation]
        orm_object.ordered_members = []
        member_ids.each do |member|
          orm_object.resource << [orm_object.resource.rdf_subject, member_predicate, ActiveFedora::Base.id_to_uri(member)]
          length = orm_object.ordered_member_proxies.to_a.length
          orm_object.ordered_member_proxies.insert_target_id_at(length, member)
        end
      end

      def member_ids
        Array.wrap(model.attributes[:member_ids]).map(&:to_s)
      end

      def resource_factory
        ::Valkyrie::Persistence::ActiveFedora::ResourceFactory
      end
  end

  class FedoraAttributes
    attr_reader :attributes
    def initialize(attributes)
      @attributes = attributes
    end

    def result
      Hash[
        attributes.map do |value|
          Value.for(value).result
        end.select(&:present?)
      ]
    end
    class Value < ::Valkyrie::ValueMapper
    end

    class EmptyHash < ::Valkyrie::ValueMapper
      Value.register(self)
      def self.handles?(value)
        value.last.nil?
      end

      def result
        []
      end
    end

    class NestedResourceArrayValue < ::Valkyrie::ValueMapper
      Value.register(self)
      def self.handles?(value)
        value.last.is_a?(Array) && value.last.map { |x| x.try(:class) }.include?(Hash)
      end

      def result
        ["#{value.first}_attributes".to_sym, values]
      end

      def values
        value.last.map do |val|
          calling_mapper.for([value.first, val]).result
        end.flat_map(&:last)
      end
    end

    class NestedResourceValue < ::Valkyrie::ValueMapper
      Value.register(self)
      def self.handles?(value)
        value.last.is_a?(Hash)
      end

      def result
        [value.first, FedoraAttributes.new(value.last).result]
      end
    end

    class EnumeratorValue < ::Valkyrie::ValueMapper
      Value.register(self)
      def self.handles?(value)
        value.last.is_a?(Array)
      end

      def result
        [value.first, values]
      end

      def values
        value.last.map do |val|
          calling_mapper.for([value.first, val]).result
        end.flat_map(&:last)
      end
    end
  end
end
