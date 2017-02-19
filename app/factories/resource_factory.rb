# frozen_string_literal: true
class ResourceFactory
  class_attribute :adapter
  # self.adapter = Valkyrie::Persistence::Postgres
  self.adapter = Valkyrie::Persistence::Fedora
  class << self
    delegate :to_model, :from_model, to: :delegate_class
    def delegate_class
      new(adapter: adapter)
    end
  end

  attr_reader :adapter
  delegate :to_model, :from_model, to: :adapter_class
  def initialize(adapter:)
    @adapter = adapter
  end

  def adapter_class
    "#{adapter}::ResourceFactory".constantize
  end
end
