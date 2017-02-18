# frozen_string_literal: true
module ModelControllerBehavior
  extend ActiveSupport::Concern
  included do
    class_attribute :form_class, :resource_class
  end

  def new
    @form = form_class.new(resource_class.new)
  end

  def create
    @form = PersistableForm.new(form_class.new(resource_class.new))
    if @form.validate(model_params)
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
    @form = PersistableForm.new(form_class.new(find_book(params[:id])))
    if @form.validate(model_params)
      @form.sync
      obj = persister.save(@form)
      redirect_to solr_document_path(id: ResourceFactory.new(adapter: ::Valkyrie::Persistence::Solr).from_model(obj).id)
    else
      render :edit
    end
  end

  private

    # Include 'curation_concerns/base' in the search path for views, while prefering
    # our local paths. Thus we are unable to just override `self.local_prefixes`
    def _prefixes
      @_prefixes ||= super + ['books']
    end

    def contextual_path(obj, form)
      ContextualPath.new(obj.id, form.append_id)
    end

    def find_book(id)
      QueryService.find_by(id: id)
    end

    def persister
      Indexer.new(Persister)
    end
end
