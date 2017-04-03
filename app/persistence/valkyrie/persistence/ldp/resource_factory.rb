# frozen_string_literal: true
module Valkyrie::Persistence::LDP
  class ResourceFactory
    attr_reader :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def from_model(model)
      FromModel.new(model: model, client: client).resource
    end

    def to_model(orm_obj)
      ToModel.new(orm: orm_obj).model
    end

    private

      def client
        adapter.connection
      end

      class ToModel
        attr_reader :orm
        def initialize(orm:)
          @orm = orm
        end

        def model
          model_klass.new(attributes)
        end

        private

          def attributes
            Hash[available_attributes.map do |property, statements|
              property = build_property(property)
              statements = statements.map { |x| cast(x.object) }
              [property, statements]
            end].merge(id: orm_id)
          end

          def cast(value)
            if value.is_a?(::RDF::Literal) && value.language.nil?
              value.to_s
            else
              value
            end
          end

          def available_attributes
            orm.graph.group_by(&:predicate).select do |property, _statements|
              build_property(property) != "hasModel"
            end
          end

          def orm_id
            orm.subject.gsub(orm.client.http.url_prefix.to_s, '').gsub(/^\//, '')
          end

          def model_klass
            @model_klass ||= orm.graph.query([nil, build_uri("hasModel"), nil]).objects.first.to_s.constantize
          end

          def build_property(uri)
            uri.to_s.gsub("http://fakeuri.com/", "")
          end

          def build_uri(property)
            RDF::URI("http://fakeuri.com/#{property}")
          end
      end

      class FromModel
        attr_reader :model, :client
        def initialize(model:, client:)
          @model = model
          @client = client
        end

        def resource
          @resource ||= ::Ldp::Resource::RdfSource.new(client, subject_uri).tap do |o|
            model.attributes.each do |property, values|
              Array.wrap(values).each do |value|
                o.graph.insert([o.subject_uri, build_uri(property), value])
              end
            end
            o.graph.insert([o.subject_uri, build_uri("hasModel"), model.resource_class.to_s])
          end
        end

        def subject_uri
          if model.id.blank?
            nil
          else
            "/#{model.id}"
          end
        end

        def build_uri(property)
          RDF::URI("http://fakeuri.com/#{property}")
        end
      end
  end
end
