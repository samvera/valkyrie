# frozen_string_literal: true
class BooksController < ApplicationController
  include ModelControllerBehavior
  self.resource_class = Book

  def append
    @form = form_class.new(resource_class.new, append_id: params[:id])
  end

  def file_manager
    @record = form_class.new(find_book(params[:id]))
    @children = FindMembersQuery.new(@record).run.map do |x|
      form_class.new(x)
    end.to_a
  end

  private

    def form_class
      DynamicFormClass.new(params[:model])
    end

    def resource_class
      Book
    end

    def model_params
      params[:book]
    end
end
