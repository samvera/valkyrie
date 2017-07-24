# frozen_string_literal: true
class FileSetsController < ApplicationController
  include Valkyrie::ControllerConcerns::ModelControllerBehavior
  self.change_set_class = FileSetChangeSet
  self.resource_class = FileSet

  def resource_params
    params[:file_set]
  end
end
