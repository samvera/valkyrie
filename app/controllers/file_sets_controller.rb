# frozen_string_literal: true
class FileSetsController < ApplicationController
  include ModelControllerBehavior
  self.form_class = FileSetForm
  self.resource_class = FileSet

  def model_params
    params[:file_set]
  end
end
