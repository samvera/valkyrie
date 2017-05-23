# frozen_string_literal: true
module Valkyrie
  class AccessControlsIndexer
    attr_reader :resource
    def initialize(resource:)
      @resource = resource
    end

    def to_solr
      {
        Hydra.config[:permissions][:read].group => resource.read_groups,
        Hydra.config[:permissions][:read].individual => resource.read_users
      }
    end
  end
end
