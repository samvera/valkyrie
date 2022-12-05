# frozen_string_literal: true
require 'active_record'
require 'erb'

module DatabaseConnection
  def self.connect!(env)
    # Ref https://github.com/puma/puma#clustered-mode
    ActiveSupport.on_load(:active_record) do
      ::ActiveRecord::Base.connection_pool.disconnect! if ::ActiveRecord::Base.connected?
      ::ActiveRecord::Base.configurations = YAML.safe_load(ERB.new(File.read("db/config.yml")).result, aliases: true) || {}
      ::ActiveRecord::Base.establish_connection(DatabaseConnection.database_config(env))
    end
  end

  def self.database_config(env)
    if ::ActiveRecord::Base.configurations.respond_to?(:configs_for)
      config = ::ActiveRecord::Base.configurations.configs_for(env_name: env.to_s)[0]
      if config.respond_to?(:configuration_hash)
        config.configuration_hash
      else
        config.config
      end
    else
      ::ActiveRecord::Base.configurations[env.to_s]
    end
  end
end
