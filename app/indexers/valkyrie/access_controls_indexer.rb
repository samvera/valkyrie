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
        Hydra.config[:permissions][:read].individual => resource.read_users,
        Hydra.config[:permissions][:edit].individual => resource.edit_users,
        Hydra.config[:permissions][:edit].group => resource.edit_groups
      }
    end
  end
end
