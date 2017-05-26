# frozen_string_literal: true
class CollectionsController < ApplicationController
  include Valkyrie::ControllerConcerns::ModelControllerBehavior
  self.form_class = CollectionForm
  self.resource_class = Collection

  def model_params
    params[:collection]
  end
end
