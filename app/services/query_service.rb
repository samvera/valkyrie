# frozen_string_literal: true
class QueryService
  class_attribute :adapter
  self.adapter = Valkyrie.config.adapter
  class << self
    delegate :find_all, :find_by_id, :find_members, to: :default_adapter

    def default_adapter
      new(adapter: adapter)
    end
  end

  attr_reader :adapter
  delegate :find_all, :find_by_id, :find_members, to: :adapter_query_service
  def initialize(adapter:)
    @adapter = adapter
  end

  delegate :query_service, to: :adapter, prefix: true
end
