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
    # Returns a derivative service for an object.
    # @param model [Valkyrie::Model]
    # @return [Valkyrie::DerivativeService]
    def self.for(form)
      services.map { |service| service.new(form) }.find(&:valid?) ||
        new(form)
    end
    attr_reader :form
    delegate :mime_type, :uri, to: :form
    # @param model [Valkyrie::Model]
    def initialize(form)
      @form = form
    end

    # Deletes any derivatives generated.
    def cleanup_derivatives; end

    # Creates derivatives.
    def create_derivatives; end

    # Returns true if the given model is valid for this derivative service.
    # @return [Boolean]
    def valid?
      true
    end
  end
end
