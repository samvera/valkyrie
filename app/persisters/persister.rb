# frozen_string_literal: true
class Persister
  class_attribute :adapter
  self.adapter = Valkyrie.config.metadata_adapter
  class << self
    delegate :save, :delete, :persister, to: :default_adapter

    def default_adapter
      new(adapter: adapter)
    end
  end

  delegate :save, :delete, :persister, to: :adapted_persister
  def initialize(adapter:)
    @adapter = adapter
  end

  def adapted_persister
    adapter.persister
  end
end
