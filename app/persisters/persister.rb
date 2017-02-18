class Persister
  class_attribute :adapter
  self.adapter = Valkyrie::Persistence::Postgres::Persister
  class << self
    delegate :save, :persister, to: :adapter
  end

  class ObjectNotFoundError < StandardError
  end
end
