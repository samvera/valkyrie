# frozen_string_literal: true
module Processors
  class AppendProcessor
    class Factory
      attr_reader :form
      def initialize(form:)
        @form = form
      end

      def new(hsh_args)
        Processors::AppendProcessor.new(hsh_args.merge(form: form))
      end
    end
    attr_reader :persister, :form
    delegate :model, to: :persister
    delegate :append_id, to: :form
    def initialize(persister:, form:)
      @persister = persister
      @form = form
    end

    def run
      return unless append_id.present?
      parent = FindByIdQuery.new(Book, append_id).run
      parent.member_ids = parent.member_ids + [model.id]
      Indexer.new(Persister).save(parent)
    end
  end
end
