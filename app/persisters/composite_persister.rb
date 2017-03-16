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

  def save(model)
    persisters.each do |persister|
      model = persister.save(model)
    end
    model
  end

  def delete(model)
    persisters.each do |persister|
      model = persister.delete(model)
    end
    model
  end
end
