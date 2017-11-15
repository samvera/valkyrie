# frozen_string_literal: true
require 'hydra/derivatives'
module Valkyrie
  ##
  # Container for registering DerivativeServices.
  #
  # To add a new service:
  #   DerivativeService.services << MyDerivativeService
  class DerivativeService
    require 'valkyrie/local_file_service'
    require 'valkyrie/persist_derivatives'
    Hydra::Derivatives.source_file_service = Valkyrie::LocalFileService
    Hydra::Derivatives.output_file_service = Valkyrie::PersistDerivatives
    class_attribute :services
    self.services = []
    # Returns a derivative service for a change_set.
    # @param resource [Valkyrie::ChangeSet]
    # @return [Valkyrie::DerivativeService]
    def self.for(change_set)
      services.map { |service| service.new(change_set) }.find(&:valid?) ||
        new(change_set)
    end
    attr_reader :change_set
    delegate :mime_type, :uri, to: :change_set
    # @param resource [Valkyrie::Resource]
    def initialize(change_set)
      @change_set = change_set
    end

    # Deletes any derivatives generated.
    def cleanup_derivatives; end

    # Creates derivatives.
    def create_derivatives; end

    # Returns true if the given resource is valid for this derivative service.
    # @return [Boolean]
    def valid?
      true
    end
  end
end
