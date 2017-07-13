# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class QueryService
    attr_reader :adapter
    delegate :cache, to: :adapter
    # @param adapter [Valkyrie::Persistence::Memory::MetadataAdapter] The adapter which
    #   has the cache to query.
    def initialize(adapter:)
      @adapter = adapter
    end

    # @param id [Valkyrie::ID] The ID to query for.
    # @raise [Valkyrie::Persistence::ObjectNotFoundError] Raised when the ID
    #   isn't in the persistence backend.
    # @return [Valkyrie::Model] The object being searched for.
    def find_by(id:)
      cache[id] || raise(::Valkyrie::Persistence::ObjectNotFoundError)
    end

    # @return [Array<Valkyrie::Model>] All objects in the persistence backend.
    def find_all
      cache.values
    end

    # @param model [Class] Class to query for.
    # @return [Array<Valkyrie::Model>] All objects in the persistence backend
    #   with the given class.
    def find_all_of_model(model:)
      cache.values.select do |obj|
        obj.is_a?(model)
      end
    end

    # @param model [Valkyrie::Model] Model whose members are being searched for.
    # @return [Array<Valkyrie::Model>] All child objects referenced by `model`'s
    #   `member_ids` method. Returned in order.
    def find_members(model:)
      member_ids(model: model).map do |id|
        find_by(id: id)
      end
    end

    # @param model [Valkyrie::Model] Model whose property is being searched.
    # @param property [Symbol] Property which, on the `model`, contains {Valkyrie::ID}s which are
    #   to be de-referenced.
    # @return [Array<Valkyrie::Model>] All objects which are referenced by the
    #   `property` property on `model`. Not necessarily in order.
    def find_references_by(model:, property:)
      Array.wrap(model[property]).map do |id|
        find_by(id: id)
      end
    end

    # @param model [Valkyrie::Model] The model which is being referenced by
    #   other models.
    # @param property [Symbol] The property which, on other models, is
    #   referencing the given `model`
    # @return [Array<Valkyrie::Model>] All models in the persistence backend
    #   which have the ID of the given `model` in their `property` property. Not
    #   in order.
    def find_inverse_references_by(model:, property:)
      find_all.select do |obj|
        Array.wrap(obj[property]).include?(model.id)
      end
    end

    # @param model [Valkyrie::Model] The model whose parents are being searched
    #   for.
    # @return [Array<Valkyrie::Model>] All models which are parents of the given
    #   `model`. This means the model's `id` appears in their `member_ids`
    #   array.
    def find_parents(model:)
      cache.values.select do |record|
        member_ids(model: record).include?(model.id)
      end
    end

    def member_ids(model:)
      model.member_ids || []
    end
  end
end
