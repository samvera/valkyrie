# frozen_string_literal: true
module NullPersistence
  class MetadataAdapter
    def persister
      @persister ||= Persister.new
    end

    def query_service
      @query_service ||= QueryService.new
    end
  end

  class Persister
    def save(resource:)
      resource
    end

    def save_all(resources:)
      resources
    end

    def delete(resource:)
      nil
    end

    def wipe!
      nil
    end
  end

  class QueryService
    def find_by(id:)
      raise ::Valkyrie::Persistence::ObjectNotFoundError
    end

    def find_all
      []
    end

    def find_all_of_model(model:)
      []
    end

    def find_members(resource:, model: nil)
      []
    end

    def find_references_by(resource:, property:)
      []
    end

    def find_inverse_references_by(resource:, property:)
      []
    end

    def find_parents(resource:)
      []
    end

    def gone?(id:)
      false
    end
  end
end
