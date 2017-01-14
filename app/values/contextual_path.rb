# frozen_string_literal: true
class ContextualPath
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::PolymorphicRoutes
  attr_reader :solr_document, :parent_document
  def initialize(solr_document, parent_document = nil)
    @solr_document = solr_document
    @parent_document = parent_document
  end

  def show
    if parent_document
      polymorphic_path([:parent, :solr_document], parent_id: parent_document, id: solr_document)
    else
      polymorphic_path([:solr_document], id: solr_document)
    end
  end
end
