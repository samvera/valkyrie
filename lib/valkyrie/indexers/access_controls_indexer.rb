# frozen_string_literal: true
module Valkyrie::Indexers
  class AccessControlsIndexer
    attr_reader :resource, :config
    def initialize(resource:, config: default_config)
      @resource = resource
      @config = config
    end

    def to_solr
      return {} unless resource.respond_to?(:read_users)
      {
        config.fetch(:read_groups) => resource.read_groups,
        config.fetch(:read_users) => resource.read_users,
        config.fetch(:edit_users) => resource.edit_users,
        config.fetch(:edit_groups) => resource.edit_groups
      }
    end

    private

      # rubocop:disable Metrics/MethodLength
      def default_config
        if Hydra.respond_to?(:config)
          {
            read_groups: Hydra.config[:permissions][:read].group,
            read_users: Hydra.config[:permissions][:read].individual,
            edit_groups: Hydra.config[:permissions][:edit].group,
            edit_users: Hydra.config[:permissions][:edit].group
          }
        else
          {
            read_groups: 'read_access_group_ssim',
            read_users: 'read_access_person_ssim',
            edit_groups: 'edit_access_group_ssim',
            edit_users: 'edit_access_person_ssim'
          }
        end
      end
    # rubocop:enable Metrics/MethodLength
  end
end
