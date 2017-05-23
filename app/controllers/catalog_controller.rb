# frozen_string_literal: true
class CatalogController < ApplicationController
  include ::Hydra::Catalog
  include Catalog
  before_action :parent_document, only: :show
  layout "valkyrie"

  def parent_document
    return unless params[:parent_id]
    _, @parent_document = fetch("id-#{params[:parent_id]}")
  end

  def has_search_parameters?
    !params[:q].nil? || !params[:f].blank? || !params[:search_field].blank?
  end
end
