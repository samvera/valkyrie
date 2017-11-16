# frozen_string_literal: true
require 'ruby_tika_app'

module Valkyrie
  # Abstract base class for file characterization
  # registers file characterization service a ValkyrieFileCharacterization service
  # initializes the interface for file characterization
  # @since 0.1.0
  class FileCharacterizationService
    class_attribute :services
    self.services = []
    # initializes the file characterization service
    # @param file_node [FileNode] the FileNode to be characterized
    # @param persister [AppendingPersister] the Persister used to save the FileNode
    # @return [TikaFileCharacterizationService] the file characterization service, currently only TikaFileCharacterizationService is implemented
    def self.for(file_node:, persister:)
      services.map { |service| service.new(file_node: file_node, persister: persister) }.find(&:valid?) ||
        new(file_node: file_node, persister: persister)
    end
    attr_reader :file_node, :persister
    delegate :mime_type, :height, :width, :checksum, to: :file_node
    def initialize(file_node:, persister:)
      @file_node = file_node
      @persister = persister
    end

    # characterizes the file_node passed into this service
    # Default options are:
    #   save: true
    # @param save [Boolean] should the persister save the file_node after Characterization
    # @return [FileNode]
    def characterize(save: true)
      persister.save(resource: @file_node) if save
      @file_node
    end

    # Stub function that sets this service as valid for all FileNode types
    def valid?
      true
    end
  end
end
