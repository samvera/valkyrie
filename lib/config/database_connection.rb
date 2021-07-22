# frozen_string_literal: true
require 'active_record'
require 'erb'

module DatabaseConnection
  def self.connect!(env)
    # Ref https://github.com/puma/puma#clustered-mode
    ActiveSupport.on_load(:active_record) do
      ::ActiveRecord::Base.connection_pool.disconnect! if ::ActiveRecord::Base.connected?
      ::ActiveRecord::Base.configurations = YAML.safe_load(ERB.new(File.read("db/config.yml")).result, [], [], true) || {}
      # configs_for is replacing deprecated [] call on configurations - ternary to bridge rails versions
      config = ::ActiveRecord::Base.configurations.respond_to?(:configs_for) ? ::ActiveRecord::Base.configurations.configs_for(env_name: env.to_s).first.configuration_hash : ::ActiveRecord::Base.configurations[env.to_s]
      ::ActiveRecord::Base.establish_connection(config)
    end
  end
end
