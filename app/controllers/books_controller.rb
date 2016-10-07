# frozen_string_literal: true
class BooksController < ApplicationController
  def new
    @form = form_class.new(resource_class.new)
  end

  def create
    @form = form_class.new(resource_class.new)
    if @form.validate(params[:book])
      @form.sync
      obj = persister.save(@form.model)
      redirect_to solr_document_path(id: Mapper.new(obj).id)
    else
      render :new
    end
  end

  def edit
    @form = form_class.new(find_book(params[:id]))
    render :edit
  end

  def update
    @form = form_class.new(find_book(params[:id]))
    if @form.validate(params[:book])
      @form.sync
      obj = persister.save(@form.model)
      redirect_to solr_document_path(id: Mapper.new(obj).id)
    else
      render :edit
    end
  end

  private

    def find_book(id)
      FindByIdQuery.new(resource_class, id).run
    end

    def persister
      Indexer.new(Persister)
    end

    def form_class
      BookForm
    end

    def resource_class
      Book
    end
end
