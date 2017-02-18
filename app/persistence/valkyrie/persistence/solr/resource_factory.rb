# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class ResourceFactory
    class << self
      def from_orm(solr_document); end

      def from_model(model)
        ::SolrDocument.new(::Valkyrie::Persistence::Solr::Mapper.find(model).to_h)
      end
    end
  end
end
