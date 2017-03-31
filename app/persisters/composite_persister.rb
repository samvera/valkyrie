# frozen_string_literal: true
class CompositePersister
  attr_reader :persisters
  def initialize(*persisters)
    @persisters = persisters
  end

  # Not sure what to do here...
  def adapter
    persisters.first.adapter
  end

  def save(model:)
    persisters.inject(model) { |m, persister| persister.save(model: m) }
  end

  def delete(model:)
    persisters.inject(model) { |m, persister| persister.delete(model: m) }
  end
end
