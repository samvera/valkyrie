# frozen_string_literal: true
require_relative 'database_connection'
DatabaseConnection.connect!(ENV['RACK_ENV'])
