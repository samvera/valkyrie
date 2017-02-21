# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class Persister
    class << self
      def save(model)
        new(sync_object: sync_object(model), post_processors: post_processors(model)).persist
      end

      def sync_object(model)
        ::Valkyrie::Persistence::Postgres::ORMSyncer.new(model: model)
      end

      def post_processors(model)
        [::Valkyrie::Persistence::Postgres::Processors::AppendProcessor::Factory.new(form: model)]
      end
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
end
