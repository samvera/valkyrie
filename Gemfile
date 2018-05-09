# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in valkyrie.gemspec
gemspec

if ENV["ACTIVERECORD_VERSION"]
  if ENV['ACTIVERECORD_VERSION'] == 'edge'
    gem 'activerecord', github: 'rails/rails'
  else
    gem 'activerecord', ENV["ACTIVERECORD_VERSION"]
  end
end
