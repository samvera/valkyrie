# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora
  class ResourceFactory
    class << self
      def to_model(orm_obj)
        return solr_to_model(orm_obj) if orm_obj.is_a?(ActiveFedora::SolrHit)
        ::Valkyrie::Persistence::ActiveFedora::DynamicKlass.new(orm_obj)
      end

      def from_model(model)
        resource =
          begin
            ::Valkyrie::Persistence::ActiveFedora::ORM::Resource.find(model.id.to_s)
          rescue
            ::Valkyrie::Persistence::ActiveFedora::ORM::Resource.new
          end
        resource.internal_model = model.internal_model
        resource
      end

      private

        def solr_to_model(orm_obj)
          ::Valkyrie::Persistence::ActiveFedora::DynamicKlass.new(SolrFaker.new(orm_obj))
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

          def ordered_member_ids
            solr_hit.fetch("member_ids_ssim", [])
          end

          def read_groups
            solr_hit.fetch("read_access_group_ssim", [])
          end

          def read_users
            solr_hit.fetch("read_access_person_ssim", [])
          end

          def edit_groups
            solr_hit.fetch("edit_access_group_ssim", [])
          end

          def edit_users
            solr_hit.fetch("edit_access_person_ssim", [])
          end

          def internal_model
            Array.wrap(solr_hit.fetch("internal_model_ssim")).first
          end

          def method_missing(meth_name, *args)
            return super if args.present?
            solr_hit["#{meth_name}_ssim"] || super
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
