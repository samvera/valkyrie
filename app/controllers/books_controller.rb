# frozen_string_literal: true
class BooksController < ApplicationController
  include Valkyrie::ControllerConcerns::ModelControllerBehavior
  self.resource_class = Book

  def append
    @change_set = change_set_class.new(resource_class.new)
    authorize! :update, @change_set.model
    @change_set.append_id = params[:id]
  end

  def file_manager
    @record = change_set_class.new(find_book(params[:id])).prepopulate!
    authorize! :file_manager, @record.model
    @children = QueryService.find_members(model: @record).map do |x|
      change_set_class.new(x).prepopulate!
    end.to_a
  end

  private

    def change_set_class
      DynamicChangeSetClass.new(params[:model])
    end

    def resource_class
      Book
    end

    def model_params
      params[:book]
    end
end
