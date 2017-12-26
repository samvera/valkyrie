# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindMembersQuery
    attr_reader :resource, :connection, :resource_factory, :model
    def initialize(resource:, connection:, resource_factory:, model:)
      @resource = resource
      @connection = connection
      @resource_factory = resource_factory
      @model = model
    end

    def run
      enum_for(:each)
    end

    def each
      return [] unless resource.id.present?
      unordered_members.sort_by { |x| member_ids.index(x.id) }.each do |member|
        yield member
      end
    end

    def unordered_members
      docs.map do |doc|
        resource_factory.to_resource(object: doc)
      end
    end

    def docs
      options = { q: query, rows: 1_000_000_000 }
      options[:fq] = "{!raw f=internal_resource_ssim}#{model}" if model
      options[:defType] = 'lucene'
      result = connection.get("select", params: options)
      result["response"]["docs"]
    end

    def member_ids
      Array.wrap(resource.member_ids)
    end

    def query
      "{!join from=#{MEMBER_IDS} to=join_id_ssi}id:#{id}"
    end

    def id
      resource.id.to_s
    end
  end
end
