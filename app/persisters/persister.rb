class Persister
  class_attribute :adapter
  self.adapter = Valkyrie::Persistence::Postgres
  class << self
    delegate :save, :persister, to: :default_adapter

    def default_adapter
      self.new(adapter: adapter)
    end
  end

  delegate :save, :persister, to: :adapted_persister
  def initialize(adapter:)
    @adapter = adapter
  end

  def adapted_persister
    "#{adapter}::Persister".constantize
  end

  class ObjectNotFoundError < StandardError
  end
end
