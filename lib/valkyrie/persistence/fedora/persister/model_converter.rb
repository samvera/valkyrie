# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    # Responsible for converting {Valkyrie::Resource} to {LDP::Container::Basic}
    class ModelConverter
      attr_reader :resource, :adapter, :subject_uri
      delegate :connection, :connection_prefix, :base_path, to: :adapter
      def initialize(resource:, adapter:, subject_uri: RDF::URI(""))
        @resource = resource
        @adapter = adapter
        @subject_uri = subject_uri
      end

      def convert
        graph_resource.graph.delete([nil, nil, nil])
        properties.each do |property|
          values = resource_attributes[property]

          output = property_converter.for(Property.new(subject_uri, property, values, adapter, resource)).result
          graph_resource.graph << output.to_graph
        end
        graph_resource
      end

      def properties
        resource_attributes.keys - [:new_record]
      end

      delegate :attributes, to: :resource, prefix: true

      def graph_resource
        @graph_resource ||= ::Ldp::Container::Basic.new(connection, subject, nil, base_path)
      end

      def subject
        adapter.id_to_uri(resource.id) if resource.try(:id)
      end

      def property_converter
        FedoraValue
      end

      class Property
        attr_reader :key, :value, :subject, :adapter, :resource
        delegate :schema, to: :adapter

        def initialize(subject, key, value, adapter, resource)
          @subject = subject
          @key = key
          @value = value
          @adapter = adapter
          @resource = resource
        end

        def to_graph(graph = RDF::Graph.new)
          Array(value).each do |val|
            graph << RDF::Statement.new(subject, predicate, val)
          end
          graph
        end

        def predicate
          schema.predicate_for(resource: resource, property: key)
        end
      end

      class CompositeProperty
        attr_reader :properties
        def initialize(properties)
          @properties = properties
        end

        def to_graph(graph = RDF::Graph.new)
          properties.each do |property|
            property.to_graph(graph)
          end
          graph
        end
      end

      class GraphProperty
        attr_reader :key, :graph, :subject, :adapter, :resource
        def initialize(subject, key, graph, adapter, resource)
          @subject = subject
          @key = key
          @graph = graph
          @adapter = adapter
          @resource = resource
        end

        def to_graph(passed_graph = RDF::Graph.new)
          passed_graph << graph
        end
      end

      class FedoraValue < ::Valkyrie::ValueMapper
      end

      class OrderedProperties < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && ordered?(value) && Array(value.value).present?
        end

        def self.ordered?(value)
          return false unless value.resource.class.schema[value.key]
          value.resource.class.schema[value.key].meta.try(:[], :ordered)
        end

        delegate :subject, to: :value

        def result
          initialize_list
          apply_first_and_last
          GraphProperty.new(value.subject, value.key, graph, value.adapter, value.resource)
        end

        def graph
          @graph ||= ordered_list.to_graph
        end

        def apply_first_and_last
          return if ordered_list.to_a.empty?
          graph << RDF::Statement.new(subject, predicate, node_id)
          graph << RDF::Statement.new(node_id, ::RDF::Vocab::IANA.first, ordered_list.head.next.rdf_subject)
          graph << RDF::Statement.new(node_id, ::RDF::Vocab::IANA.last, ordered_list.tail.prev.rdf_subject)
        end

        def node_id
          @node_id ||= ordered_list.send(:new_node_subject)
        end

        def predicate
          value.schema.predicate_for(resource: value.resource, property: value.key)
        end

        def initialize_list
          Array(value.value).each_with_index do |val, index|
            ordered_list.insert_proxy_for_at(index, calling_mapper.for(Property.new(value.subject, value.key.to_s.singularize.to_sym, val, value.adapter, value.resource)).result.value)
          end
        end

        def ordered_list
          @ordered_list ||= OrderedList.new(RDF::Graph.new, nil, nil, value.adapter)
        end
      end

      class NestedProperty < ::Valkyrie::ValueMapper
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Hash) && value.value[:internal_resource]
        end

        def result
          nested_graph << RDF::Statement.new(value.subject, value.predicate, subject_uri)
          GraphProperty.new(value.subject, value.key, nested_graph, value.adapter, value.resource)
        end

        def nested_graph
          @nested_graph ||= ModelConverter.new(resource: Valkyrie::Types::Anything[value.value], adapter: value.adapter, subject_uri: subject_uri).convert.graph
        end

        def subject_uri
          @subject_uri ||= ::RDF::URI(RDF::Node.new.to_s.gsub("_:", "#"))
        end
      end

      class MappedFedoraValue < ::Valkyrie::ValueMapper
        private

          def map_value(converted_value:)
            calling_mapper.for(
              Property.new(
                value.subject,
                value.key,
                converted_value,
                value.adapter,
                value.resource
              )
            ).result
          end
      end

      class NestedInternalValkyrieID < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Valkyrie::ID) && value.subject.to_s.include?("#")
        end

        def result
          map_value(converted_value: RDF::Literal.new(
            value.value,
            datatype: PermissiveSchema.valkyrie_id
          ))
        end
      end

      class InternalValkyrieID < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Valkyrie::ID) && !value.value.to_s.include?("://")
        end

        def result
          map_value(converted_value: value.adapter.id_to_uri(value.value))
        end
      end

      class BooleanValue < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && ([true, false].include? value.value)
        end

        def result
          map_value(converted_value: RDF::Literal.new(
            value.value,
            datatype: PermissiveSchema.valkyrie_bool
          ))
        end
      end

      class IntegerValue < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Integer)
        end

        def result
          map_value(converted_value: RDF::Literal.new(
            value.value,
            datatype: PermissiveSchema.valkyrie_int
          ))
        end
      end

      class DateTimeValue < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(DateTime)
        end

        def result
          map_value(converted_value: RDF::Literal.new(
            value.value,
            datatype: PermissiveSchema.valkyrie_datetime
          ))
        end
      end

      # technically valkyrie does not support time, but when other persister support time
      #  this code will make fedora compliant
      #
      #  https://github.com/samvera-labs/valkyrie/wiki/Supported-Data-Types
      class TimeValue < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Time)
        end

        def result
          # cast it to datetime for storage, to preserve miliseconds and date
          map_value(converted_value:
              RDF::Literal.new(
                value.value.to_datetime,
                datatype: PermissiveSchema.valkyrie_time
              ))
        end
      end

      class IdentifiableValue < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Valkyrie::ID)
        end

        def result
          map_value(converted_value: RDF::Literal.new(
            value.value,
            datatype: PermissiveSchema.valkyrie_id
          ))
        end
      end

      class EnumerableValue < MappedFedoraValue
        FedoraValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Array)
        end

        def result
          new_values = value.value.map do |val|
            map_value(converted_value: val)
          end
          CompositeProperty.new(new_values)
        end
      end
    end
  end
end
