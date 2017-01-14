# frozen_string_literal: true
module Processors
  class AppendProcessor
    attr_reader :persister
    delegate :model, :form, to: :persister
    delegate :append_id, to: :form
    def initialize(persister:)
      @persister = persister
    end

    def run
      return unless append_id.present?
      parent = FindByIdQuery.new(Book, append_id).run
      parent.member_ids = parent.member_ids + [model.id]
      Indexer.new(Persister).save(parent)
    end
  end
end
