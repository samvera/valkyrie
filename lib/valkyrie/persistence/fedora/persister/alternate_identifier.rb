# frozen_string_literal: true
require 'valkyrie/resource'
require 'valkyrie/types'

module Valkyrie::Persistence::Fedora
  class AlternateIdentifier < ::Valkyrie::Resource
    attribute :id, ::Valkyrie::Types::ID.optional
    attribute :references, ::Valkyrie::Types::ID.optional
  end
end
