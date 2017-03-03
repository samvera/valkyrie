# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class ResourceFactory
    class << self
      def adapter
        Valkyrie::Persistence::Fedora
      end

      def to_model(orm_obj)
        return solr_to_model(orm_obj) if orm_obj.is_a?(ActiveFedora::SolrHit)
        ::Valkyrie::Persistence::Fedora::DynamicKlass.new(orm_obj)
      end

      def from_model(model)
        resource =
          begin
            ::Valkyrie::Persistence::Fedora::ORM::Resource.find(model.id)
          rescue
            ::Valkyrie::Persistence::Fedora::ORM::Resource.new
          end
        resource.internal_model = [model.resource_class.to_s]
        resource
      end

      private

        def solr_to_model(orm_obj)
          ::Valkyrie::Persistence::Fedora::DynamicKlass.new(SolrFaker.new(orm_obj))
        end

        class SolrFaker
          attr_reader :solr_hit
          delegate :id, to: :solr_hit
          def initialize(solr_hit)
            @solr_hit = solr_hit
          end

          def attributes
            attribute_hash.merge("id" => id)
          end

          def member_ids
            solr_hit.fetch("member_ids_ssim", [])
          end

          def ordered_member_ids
            solr_hit.fetch("member_ids_ssim", [])
          end

          def method_missing(meth_name, *args)
            return super if args.present?
            if solr_hit["#{meth_name}_ssim"]
              solr_hit["#{meth_name}_ssim"]
            else
              super
            end
          end

          def respond_to_missing?(meth_name)
            solr_hit["#{meth_name}_ssim"]
          end

          private

            def attribute_hash
              strip_ssim(solr_hit.select do |k, _v|
                k.end_with?("ssim")
              end)
            end

            def strip_ssim(hsh)
              Hash[
                hsh.map do |k, v|
                  [k.gsub("_ssim", ""), v]
                end
              ]
            end
        end
    end
  end
end
