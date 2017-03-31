# frozen_string_literal: true
module Penguin::Persistence::Solr
  class Mapper
    ## Find a mapper for a given object
    def self.find(obj)
      new(obj)
    end

    attr_reader :object
    delegate :id, to: :object

    def initialize(object)
      @object = object
    end

    def to_h
      {
        "id": id
      }.merge(attribute_hash)
    end

    private

      def attribute_hash
        properties.each_with_object({}) do |property, hsh|
          Value.for(property, object.__send__(property)).result.each do |key, values|
            hsh[key] = values
          end
        end
      end

      def properties
        object.attributes.keys - [:id]
      end

      class Value
        class_attribute :value_processors
        self.value_processors = []
        class << self
          def register(klass)
            value_processors << klass
          end

          def for(property, value)
            (value_processors + [Value]).find do |value_processor|
              value_processor.handles?(property, value)
            end.new(property, value)
          end

          def handles?(_property, _value)
            true
          end
        end

        attr_reader :property, :value
        def initialize(property, value)
          @property = property
          @value = value
        end

        def result
          Hash[
            suffixes.map do |suffix|
              ["#{property}_#{suffix}".to_sym, Array.wrap(value)]
            end
          ]
        end

        def suffixes
          [
            :ssim,
            :tesim
          ]
        end

        def combine_hashes(values)
          values.inject do |first_hsh, second_hsh|
            first_hsh.merge(second_hsh) do |_key, second_value, third_value|
              Array.wrap(second_value) + Array.wrap(third_value)
            end
          end
        end
      end

      class RDFLiteralValue < Value
        Value.register(self)
        class << self
          def handles?(_property, value)
            Array.wrap(value).find { |x| x.try(:term?) }
          end
        end
        def result
          combine_hashes(Array.wrap(value).map do |val|
            if val.try(:term?)
              Value.for(property, val.to_s).result.merge(
                Value.for(language_property, val.language.to_s).result
              )
            else
              Value.for(property, val).result.merge(
                Value.for(language_property, "eng").result
              )
            end
          end)
        end

        def language_property
          "#{property}_lang".to_sym
        end
      end

      class EnumeratorValue < Value
        Value.register(self)
        class << self
          def handles?(_property, value)
            value.is_a?(Enumerable)
          end
        end

        def result
          combine_hashes(value.map do |v|
            Value.for(property, v).result
          end) || {}
        end
      end
  end
end
