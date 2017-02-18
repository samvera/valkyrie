# frozen_string_literal: true
class ResourceFactory
  class_attribute :adapter
  self.adapter = Valkyrie::Persistence::Postgres
  class << self
    delegate :from_orm, :from_model, to: :delegate_class
    def delegate_class
      "#{adapter}::ResourceFactory".constantize
    end
  end
end
