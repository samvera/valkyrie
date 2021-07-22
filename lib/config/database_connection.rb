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
      # using Safe Navigation Operator - should be fine as we only test for > ruby 2.3
      config = ::ActiveRecord::Base.configurations&.configs_for(env_name: env.to_s)&.first&.configuration_hash
      config = ::ActiveRecord::Base.configurations[env.to_s] if config.nil?
      ::ActiveRecord::Base.establish_connection(config)
    end
  end
end
