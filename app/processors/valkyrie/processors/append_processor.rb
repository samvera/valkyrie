# frozen_string_literal: true
module Valkyrie::Processors
  class AppendProcessor
    attr_reader :persister, :form
    delegate :adapter, to: :persister
    def initialize(persister:, form:, adapter: nil)
      @persister = persister
      @form = form
      @adapter = adapter
    end

    def run(model:)
      return unless append_id.present?
      parent = query_service.find_by_id(append_id)
      parent.member_ids = parent.member_ids + [model.id]
      persister.save(parent)
    end

    def append_id
      form.try(:append_id)
    end

    def query_service
      QueryService.new(adapter: adapter)
    end
  end
end
