# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::Processors
  class AppendProcessor
    class Factory
      attr_reader :form
      def initialize(form:)
        @form = form
      end

      def new(hsh_args)
        ::Valkyrie::Persistence::Fedora::Processors::AppendProcessor.new(hsh_args.merge(form: form))
      end
    end
    attr_reader :persister, :form
    delegate :model, to: :persister
    def initialize(persister:, form:)
      @persister = persister
      @form = form
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
      Persister.new(adapter: ::Valkyrie::Persistence::Fedora)
    end

    def query_service
      QueryService.new(adapter: ::Valkyrie::Persistence::Fedora)
    end
  end
end
