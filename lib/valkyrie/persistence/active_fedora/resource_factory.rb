# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora
  # Convert Valkrie::Model to an ActiveFedora::Base and vice versa
  class ResourceFactory
    class << self
      # Convert an ActiveFedora::Base or ActiveFedora::SolrHit to Valkrie::Model
      # @param orm_object [Valkyrie::Persistence::ActiveFedora::ORM::Resource, ActiveFedora::SolrHit]
      # @return [Valkrie::Model]
      def to_model(orm_obj)
        return solr_to_model(orm_obj) if orm_obj.is_a?(ActiveFedora::SolrHit)
        ::Valkyrie::Persistence::ActiveFedora::DynamicKlass.new(orm_obj)
      end

      # Find or create an ActiveFedora::Base that corresponds to the identifier
      # of the Valkyrie model and encode the type of the Valkyrie model on it.
      # @param [Valkrie::Model]
      # @return [Valkyrie::Persistence::ActiveFedora::ORM::Resource]
      def from_model(model)
        if model.created_at.blank? && model.id.present?
          if ::Valkyrie::Persistence::ActiveFedora::ORM::Resource.exists?(model.id.to_s)
            raise Valkyrie::Persistence::IllegalOperation, "Attempting to recreate existing resource: `#{model.id}'"
          end
        end

        resource =
          begin
            ::Valkyrie::Persistence::ActiveFedora::ORM::Resource.find(model.id.to_s)
          rescue
            attributes = model.id.present? ? { id: model.id.to_s } : {}
            ::Valkyrie::Persistence::ActiveFedora::ORM::Resource.new(attributes)
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
            attribute_hash.merge("id" => id, "file_identifiers" => file_identifiers)
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

          def create_date
            DateTime.parse(solr_hit["system_create_dtsi"]).utc
          end

          def modified_date
            DateTime.parse(solr_hit["system_modified_dtsi"]).utc
          end

          def file_identifiers
            solr_hit.fetch("file_identifiers_ssim", []).map { |x| Valkyrie::ID.new(x) }
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
