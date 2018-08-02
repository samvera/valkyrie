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
require 'rails'

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
      YAML.safe_load(ERB.new(File.read(config_root_path.join("config", "valkyrie.yml"))).result)[environment]
    )
  end

  def environment
    Rails.env
  end

  def config_root_path
    if const_defined?(:Rails) && Rails.root
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
    def metadata_adapter
      Valkyrie::MetadataAdapter.find(super.to_sym)
    end

    def storage_adapter
      Valkyrie::StorageAdapter.find(super.to_sym)
    end
  end

  module_function :config, :logger, :logger=, :config_root_path, :environment
end
