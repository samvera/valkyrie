# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'
ENV['RAILS_ENV'] = 'test'
ENV['environment'] = 'test'
require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
  add_filter 'vendor'
  minimum_coverage 100
end
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "valkyrie"
require 'pry'
require 'action_dispatch'
require 'webmock/rspec'
require 'timecop'

SOLR_TEST_URL = "http://127.0.0.1:#{ENV['TEST_JETTY_PORT'] || 8994}/solr/valkyrie-core-test"

ROOT_PATH = Pathname.new(Dir.pwd)
Dir[Pathname.new("./").join("spec", "support", "**", "*.rb")].sort.each { |file| require_relative file.gsub(/^spec\//, "") }

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.before do
    # See Valkyrie::Logging for specific details
    Valkyrie.logger.suppress_logging_for_contexts!("Valkyrie::Persistence::Solr::Repository#generate_id")
  end

  config.after do
    # See Valkyrie::Logging for specific details
    Valkyrie.logger.clear_suppressions!
  end
end
