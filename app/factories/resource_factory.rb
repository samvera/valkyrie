# frozen_string_literal: true
class ResourceFactory
  class_attribute :adapter
  self.adapter = Valkyrie::Persistence::Postgres
  class << self
    delegate :from_orm, :from_model, to: :delegate_class
    def delegate_class
      self.new(adapter: adapter)
    end
  end

  attr_reader :adapter
  delegate :from_orm, :from_model, to: :adapter_class
  def initialize(adapter:)
    @adapter = adapter
  end

  def adapter_class
    "#{adapter}::ResourceFactory".constantize
  end
end
