# frozen_string_literal: true
# :nocov:
begin
  gem 'pg'
rescue Gem::LoadError => e
  raise Gem::LoadError,
        "You are using the Postgres adapter without installing the #{e.name} gem.  "\
        "Add `gem '#{e.name}'` to your Gemfile."
end
# :nocov:
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata into Postgres
  module Postgres
    # :nocov:
    # Deprecation to allow us to make pg an optional dependency
    path = Bundler.definition.gemfiles.first
    matches = File.readlines(path).select { |l| l =~ /gem ['"]activerecord\b/ }
    if matches.empty?
      warn "[DEPRECATION] activerecord will not be included as a dependency in Valkyrie's gemspec as of the next major release." \
        "Please add the gem directly to your Gemfile if you use a postgres adapter."
    end
    # :nocov:

    require 'valkyrie/persistence/postgres/metadata_adapter'
  end
end
