# frozen_string_literal: true
require "valkyrie/version"
require "ostruct"
require 'active_support'
require 'active_support/core_ext'
require 'dry-types'
require 'dry-struct'
require 'draper'
require 'active_record'
require 'reform'
require 'reform/active_record'
require 'rdf'
require 'valkyrie/rdf_patches'
require 'json/ld'
require 'logger'
require 'rdf/vocab'

module Valkyrie
  require 'valkyrie/id'
  require 'valkyrie/change_set'
  require 'valkyrie/value_mapper'
  require 'valkyrie/persistence'
  require 'valkyrie/types'
  require 'valkyrie/resource'
  require 'valkyrie/storage_adapter'
  require 'valkyrie/metadata_adapter'
  require 'valkyrie/adapter_container'
  require 'valkyrie/resource/access_controls'
  require 'valkyrie/indexers/access_controls_indexer'
  require 'valkyrie/storage'
  require 'valkyrie/vocab/pcdm_use'
  require 'generators/valkyrie/resource_generator'
  require 'valkyrie/engine' if defined?(Rails)
  def config
    @config ||= Config.new(
      config_hash
    )
  end

  def config_file
    return unless File.exist?(config_root_path.join("config", "valkyrie.yml"))
    File.read(config_root_path.join("config", "valkyrie.yml"))
  end

  def config_hash
    return {} unless config_file
    YAML.safe_load(ERB.new(config_file).result)[environment]
  end

  def environment
    if const_defined?(:Rails) && Rails.respond_to?(:env)
      Rails.env
    else
      ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
    end
  end

  def config_root_path
    if const_defined?(:Rails) && Rails.respond_to?(:root)
      Rails.root
    else
      Pathname.new(Dir.pwd)
    end
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def logger=(logger)
    @logger = logger
  end

  class Config < OpenStruct
    def initialize(hsh = {})
      super(defaults.merge(hsh))
    end

    def metadata_adapter
      Valkyrie::MetadataAdapter.find(super.to_sym)
    end

    def storage_adapter
      Valkyrie::StorageAdapter.find(super.to_sym)
    end

    # @api public
    #
    # The returned anonymous method (e.g. responds to #call) has a signature of
    # an unamed parameter that is a string. Calling the anonymous method should
    # return a Valkyrie::Resource from which Valkyrie will map the persisted
    # data into.
    #
    # @return [#call] with method signature of 1
    #
    # @see #default_resource_class_resolver for full interface
    def resource_class_resolver
      super
    end

    # @!attribute [w] resource_class_resolver=
    #   The setter for #resource_class_resolver; see it's implementation

    private

      def defaults
        {
          resource_class_resolver: method(:default_resource_class_resolver)
        }
      end

      # String constantize is a "by convention" factory. This works, but assumes
      # the ruby class once used to persist is the model used to now reify.
      #
      # @param [String] class_name
      def default_resource_class_resolver(class_name)
        class_name.constantize
      end
  end

  module_function :config, :logger, :logger=, :config_root_path, :environment, :config_file, :config_hash
end
