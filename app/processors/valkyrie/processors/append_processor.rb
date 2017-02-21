# frozen_string_literal: true
module Valkyrie::Processors
  class AppendProcessor
    class Factory
      attr_reader :form, :adapter
      def initialize(form:, adapter:)
        @form = form
        @adapter = adapter
      end

      def new(hsh_args)
        ::Valkyrie::Processors::AppendProcessor.new(hsh_args.merge(form: form, adapter: adapter))
      end
    end
    attr_reader :persister, :form, :adapter
    delegate :model, to: :persister
    def initialize(persister:, form:, adapter:)
      @persister = persister
      @form = form
      @adapter = adapter
    end

    def run
      return unless append_id.present?
      parent = query_service.find_by_id(append_id)
      parent.member_ids = parent.member_ids + [model.id]
      Indexer.new(new_persister).save(parent)
    end

    def append_id
      form.try(:append_id)
    end

    def new_persister
      Persister.new(adapter: adapter)
    end

    def query_service
      QueryService.new(adapter: adapter)
    end
  end
end
