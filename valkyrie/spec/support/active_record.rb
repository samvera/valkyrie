# frozen_string_literal: true
require 'config/database_connection'
DatabaseConnection.connect!(ENV['RACK_ENV'])
