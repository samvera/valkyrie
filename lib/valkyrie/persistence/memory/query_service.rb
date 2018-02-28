# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class QueryService
    # Query Service for the memory metadata adapter.
    # @see Valkyrie::Persistence::Memory
    # @note Documentation for Query Services in general is maintained here.
    attr_reader :adapter, :query_handlers
    delegate :cache, to: :adapter
    # @param adapter [Valkyrie::Persistence::Memory::MetadataAdapter] The adapter which
    #   has the cache to query.
    def initialize(adapter:)
      @adapter = adapter
      @query_handlers = []
    end

    # @param id [Valkyrie::ID] The ID to query for.
    # @raise [Valkyrie::Persistence::ObjectNotFoundError] Raised when the ID
    #   isn't in the persistence backend.
    # @return [Valkyrie::Resource] The object being searched for.
    def find_by(id:)
      id = Valkyrie::ID.new(id.to_s) if id.is_a?(String)
      validate_id(id)
      cache[id] || raise(::Valkyrie::Persistence::ObjectNotFoundError)
    end

    # @return [Array<Valkyrie::Resource>] All objects in the persistence backend.
    def find_all
      cache.values
    end

    # @param model [Class] Class to query for.
    # @return [Array<Valkyrie::Resource>] All objects in the persistence backend
    #   with the given class.
    def find_all_of_model(model:)
      cache.values.select do |obj|
        obj.is_a?(model)
      end
    end

    # @param resource [Valkyrie::Resource] Model whose members are being searched for.
    # @param model [Class] Class to query for. (optional)
    # @return [Array<Valkyrie::Resource>] child objects of type `model` referenced by
    #   `resource`'s `member_ids` method. Returned in order.
    def find_members(resource:, model: nil)
      result = member_ids(resource: resource).map do |id|
        find_by(id: id)
      end
      return result unless model
      result.select { |obj| obj.is_a?(model) }
    end

    # @param resource [Valkyrie::Resource] Model whose property is being searched.
    # @param property [Symbol] Property which, on the `resource`, contains {Valkyrie::ID}s which are
    #   to be de-referenced.
    # @return [Array<Valkyrie::Resource>] All objects which are referenced by the
    #   `property` property on `resource`. Not necessarily in order.
    def find_references_by(resource:, property:)
      Array.wrap(resource[property]).map do |id|
        find_by(id: id)
      end
    end

    # @param resource [Valkyrie::Resource] The resource which is being referenced by
    #   other resources.
    # @param property [Symbol] The property which, on other resources, is
    #   referencing the given `resource`
    # @raise [ArgumentError] Raised when the ID is not in the persistence backend.
    # @return [Array<Valkyrie::Resource>] All resources in the persistence backend
    #   which have the ID of the given `resource` in their `property` property. Not
    #   in order.
    def find_inverse_references_by(resource:, property:)
      ensure_persisted(resource)
      find_all.select do |obj|
        begin
          Array.wrap(obj[property]).include?(resource.id)
        rescue
          false
        end
      end
    end

    # @param resource [Valkyrie::Resource] The resource whose parents are being searched
    #   for.
    # @return [Array<Valkyrie::Resource>] All resources which are parents of the given
    #   `resource`. This means the resource's `id` appears in their `member_ids`
    #   array.
    def find_parents(resource:)
      cache.values.select do |record|
        member_ids(resource: record).include?(resource.id)
      end
    end

    def custom_queries
      @custom_queries ||= ::Valkyrie::Persistence::CustomQueryContainer.new(query_service: self)
    end

    private

      # @return [Array<Valkyrie::ID>] a list of the identifiers of the member objects
      def member_ids(resource:)
        return [] unless resource.respond_to? :member_ids
        resource.member_ids || []
      end

      def validate_id(id)
        raise ArgumentError, 'id must be a Valkyrie::ID' unless id.is_a? Valkyrie::ID
      end

      def ensure_persisted(resource)
        raise ArgumentError, 'resource is not saved' unless resource.persisted?
      end
  end
end
