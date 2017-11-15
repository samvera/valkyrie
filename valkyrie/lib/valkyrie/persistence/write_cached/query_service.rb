# frozen_string_literal: true
module Valkyrie::Persistence::WriteCached
  class QueryService
    # @param primary [Object] The permanent datastore query_service
    # @param cache [Object, .gone?] The expiring front-end cache query_service
    def initialize(primary:, cache:)
      @primary = primary
      @cache = cache
    end

    # @param id [Valkyrie::ID] The ID to query for.
    # @raise [Valkyrie::Persistence::ObjectNotFoundError] Raised when the ID
    #   isn't in the persistence backend.
    # @return [Valkyrie::Resource] The object being searched for.
    def find_by(id:)
      raise ::Valkyrie::Persistence::ObjectNotFoundError if @cache.respond_to?(:gone?) && @cache.gone?(id: id)
      begin
        @cache.find_by(id: id)
      rescue ::Valkyrie::Persistence::ObjectNotFoundError
        @primary.find_by(id: id)
      end
    end

    # @return [Array<Valkyrie::Resource>] All objects in the persistence backend.
    def find_all
      reconcile(:find_all)
    end

    # @param model [Class] Class to query for.
    # @return [Array<Valkyrie::Resource>] All objects in the persistence backend
    #   with the given class.
    def find_all_of_model(model:)
      reconcile(:find_all_of_model, model: model)
    end

    # @param resource [Valkyrie::Resource] Model whose members are being searched for.
    # @param model [Class] Class to query for. (optional)
    # @return [Array<Valkyrie::Resource>] child objects of type `model` referenced by
    #   `resource`'s `member_ids` method. Returned in order.
    def find_members(resource:, model: nil)
      reconcile(:find_members, resource: resource, model: model)
    end

    # @param resource [Valkyrie::Resource] Model whose property is being searched.
    # @param property [Symbol] Property which, on the `resource`, contains {Valkyrie::ID}s which are
    #   to be de-referenced.
    # @return [Array<Valkyrie::Resource>] All objects which are referenced by the
    #   `property` property on `resource`. Not necessarily in order.
    def find_references_by(resource:, property:)
      reconcile(:find_references_by, resource: resource, property: property)
    end

    # @param resource [Valkyrie::Resource] The resource which is being referenced by
    #   other resources.
    # @param property [Symbol] The property which, on other resources, is
    #   referencing the given `resource`
    # @return [Array<Valkyrie::Resource>] All resources in the persistence backend
    #   which have the ID of the given `resource` in their `property` property. Not
    #   in order.
    def find_inverse_references_by(resource:, property:)
      reconcile(:find_inverse_references_by, resource: resource, property: property)
    end

    # @param resource [Valkyrie::Resource] The resource whose parents are being searched
    #   for.
    # @return [Array<Valkyrie::Resource>] All resources which are parents of the given
    #   `resource`. This means the resource's `id` appears in their `member_ids`
    #   array.
    def find_parents(resource:)
      reconcile(:find_parents, resource: resource)
    end

    def member_ids(resource:)
      return [] unless resource.respond_to? :member_ids
      resource.member_ids || []
    end

    def custom_queries
      @custom_queries ||= ::Valkyrie::Persistence::CustomQueryContainer.new(query_service: self)
    end

    private

      def reconcile(method, *args)
        primary_result = @primary.send(method, *args)
        cache_result = @cache.send(method, *args)
        ReconcilingEnumerator.new(primary_result, cache_result, @cache).to_enum(:each)
      end
  end

  class ReconcilingEnumerator
    attr_reader :primary_list, :cache_list, :cache
    def initialize(primary_list, cache_list, cache)
      @primary_list = primary_list
      @cache_list = cache_list
      @cache = cache
    end

    def reconcile(member)
      cache.find_by(id: member.id)
    rescue ::Valkyrie::Persistence::ObjectNotFoundError
      member
    end

    def each
      new_ids = cache_list.collect(&:id) - primary_list.collect(&:id)
      result = primary_list.select do |member|
        next if cache.respond_to?(:gone?) && cache.gone?(id: member.id)
        yield reconcile(member)
        true
      end
      result + cache_list.collect do |member|
        next unless new_ids.include?(member.id)
        yield member
        member
      end
    end
  end
end
