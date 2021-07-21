# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  module ORM
    # ActiveRecord class which the Postgres adapter uses for persisting data.
    # @!attribute id
    #   @return [UUID] ID of the record
    # @!attribute metadata
    #   @return [Hash] Hash of all metadata.
    # @!attribute created_at
    #   @return [DateTime] Date created
    # @!attribute updated_at
    #   @return [DateTime] Date updated
    # @!attribute internal_resource
    #   @return [String] Name of {Valkyrie::Resource} model - used for casting.
    #
    class Resource < ActiveRecord::Base
      def disable_optimistic_locking!
        @disable_optimistic_locking = true
      end

      def locking_enabled?
        return false if @disable_optimistic_locking
        true
      end

      def self.connection_hash
        # connection_config is deprecated in ActiveRecord and being removed in Rails
        # 6.2 - this method is an alias that uses connection_db_config if defined
        # and falls back to connection_config otherwise. This allows all rails versions
        # to be supported
        if defined?(ActiveRecord::Base.connection_db_config)
          ActiveRecord::Base.connection_db_config.configuration_hash
        else
          ActiveRecord::Base.connection_config
        end
      end
    end
  end
end
