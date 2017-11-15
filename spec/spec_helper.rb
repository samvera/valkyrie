# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'
ENV['RAILS_ENV'] = 'test'
require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
)
SimpleCov.start do
  add_filter 'spec'
  add_filter 'vendor'
end
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "valkyrie"
require 'pry'

# Setup to use the fedora.yml in the test app
ActiveFedora.init(environment: ENV['RACK_ENV'],
                  fedora_config_path: File.expand_path("../../config/fedora.yml", __FILE__))

ROOT_PATH = Pathname.new(Dir.pwd)
Dir[Pathname.new("./").join("spec", "support", "**", "*.rb")].sort.each { |file| require_relative file.gsub(/^spec\//, "") }
