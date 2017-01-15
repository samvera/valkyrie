# frozen_string_literal: true
class BooksController < ApplicationController
  def new
    @form = form_class.new(resource_class.new)
  end

  def create
    @form = form_class.new(resource_class.new)
    if @form.validate(params[:book])
      @form.sync
      obj = persister.save(@form)
      redirect_to contextual_path(obj, @form).show
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
      obj = persister.save(@form)
      redirect_to solr_document_path(id: Mapper.new(obj).id)
    else
      render :edit
    end
  end

  def append
    @form = form_class.new(resource_class.new, append_id: params[:id])
  end

  def file_manager
    @record = form_class.new(find_book(params[:id]))
    @children = FindMembersQuery.new(@record).run.map { |x| form_class.new(x) }.to_a
  end

  private

    def contextual_path(obj, form)
      ContextualPath.new(obj.id, form.append_id)
    end

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
