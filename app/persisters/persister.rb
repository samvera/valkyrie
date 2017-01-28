# frozen_string_literal: true
class Persister
  class << self
    def save(model)
      persister(model).persist
    end

    def persister(model)
      Persister.new(sync_object: sync_object(model), post_processors: post_processors(model))
    end

    def sync_object(model)
      ORMSyncer.new(model: model, orm_model: ORM::Resource)
    end

    def post_processors(model)
      [Processors::AppendProcessor::Factory.new(form: model)]
    end

    def mapper
      ORMToObjectMapper
    end
  end
  class ObjectNotFoundError < StandardError
  end

  attr_reader :post_processors, :sync_object
  delegate :model, to: :sync_object

  def initialize(sync_object: nil, post_processors: [])
    @sync_object = sync_object
    @post_processors ||= post_processors
  end

  def persist
    sync_object.save
    post_processors.each do |processor|
      processor.new(persister: self).run
    end
    sync_object.model
  end
end
