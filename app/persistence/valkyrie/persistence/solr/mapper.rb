# frozen_string_literal: true
module Valkyrie::Persistence::Solr
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
        class << self
          def for(property, value)
            if value.respond_to?(:each)
              EnumeratorValue.new(property, value)
            elsif value.try(:term?)
              RDFLiteralValue.new(property, value)
            else
              Value.new(property, value)
            end
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
      end

      class RDFLiteralValue < Value
        def result
          Value.for(property, value.to_s).result.merge(
            Value.for(language_property, value.language.to_s).result
          )
        end

        def language_property
          "#{property}_lang".to_sym
        end
      end

      class EnumeratorValue < Value
        def result
          combine_hashes(value.map do |v|
            Value.for(property, v).result
          end) || {}
        end

        def combine_hashes(values)
          values.inject do |first_hsh, second_hsh|
            first_hsh.merge(second_hsh) do |_key, second_value, third_value|
              Array.wrap(second_value) + Array.wrap(third_value)
            end
          end
        end
      end
  end
end
