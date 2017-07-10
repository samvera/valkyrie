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
require 'active_triples'
require 'rdf/vocab'
require 'active_fedora'
require 'hydra-access-controls'

# frozen_string_literal: true
module Valkyrie
  require 'valkyrie/id'
  require 'valkyrie/form'
  require 'valkyrie/value_mapper'
  require 'valkyrie/persistence'
  require 'valkyrie/types'
  require 'valkyrie/model'
  require 'valkyrie/derivative_service'
  require 'valkyrie/storage_adapter'
  require 'valkyrie/adapter'
  require 'valkyrie/adapter_container'
  require 'valkyrie/decorators/decorator_list'
  require 'valkyrie/decorators/decorator_with_arguments'
  require 'valkyrie/model/access_controls'
  require 'valkyrie/indexers/access_controls_indexer'
  require 'valkyrie/vocab/pcdm_use'
  require 'valkyrie/engine' if defined?(Rails)
  def config
    Config.new(
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
    def adapter
      Valkyrie::Adapter.find(super.to_sym)
    end

    def storage_adapter
      Valkyrie::StorageAdapter.find(super.to_sym)
    end
  end

  module_function :config, :logger, :logger=, :config_root_path, :environment
end