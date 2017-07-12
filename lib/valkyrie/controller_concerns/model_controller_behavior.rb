# frozen_string_literal: true
module Valkyrie::ControllerConcerns
  module ModelControllerBehavior
    extend ActiveSupport::Concern
    included do
      class_attribute :form_class, :resource_class
    end

    def new
      @form = form_class.new(resource_class.new).prepopulate!
      authorize! :create, resource_class
      @collections = ::Draper::CollectionDecorator.decorate(query_service.find_all_of_model(model: Collection))
    end

    def create
      @form = form_class.new(resource_class.new)
      authorize! :create, @form.model
      if @form.validate(model_params)
        @form.sync
        obj = nil
        persister.buffer_into_index do |persist|
          obj = persist.save(model: @form)
          if @form.append_id
            parent_obj = query_service.find_by(id: @form.append_id)
            parent_obj.member_ids = parent_obj.member_ids + [obj.id]
            persist.save(model: parent_obj)
          end
        end
        redirect_to contextual_path(obj, @form).show
      else
        render :new
      end
    end

    def edit
      @form = form_class.new(find_book(params[:id])).prepopulate!
      authorize! :update, @form.model
      @collections = query_service.find_all_of_model(model: Collection)
      render :edit
    end

    def update
      @form = form_class.new(find_book(params[:id]))
      authorize! :update, @form.model
      if @form.validate(model_params)
        @form.sync
        obj = nil
        persister.buffer_into_index do |persist|
          obj = persist.save(model: @form)
        end
        redirect_to solr_document_path(id: solr_adapter.resource_factory.from_model(obj)[:id])
      else
        render :edit
      end
    end

    def destroy
      @resource = find_book(params[:id])
      authorize! :destroy, @resource
      persister.buffer_into_index do |persist|
        parents = query_service.find_parents(model: @resource)
        parents.each do |parent|
          parent.member_ids -= [@resource.id]
          persist.save(model: parent)
        end
        persist.delete(model: @resource)
      end
      flash[:alert] = "Deleted #{@resource}"
      redirect_to root_path
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
        QueryService.find_by(id: Valkyrie::ID.new(id.to_s))
      end

      def persister
        Valkyrie::Adapter.find(:indexing_persister).persister
      end

      def query_service
        Valkyrie::Adapter.find(:indexing_persister).query_service
      end

      def solr_adapter
        Valkyrie::Adapter.find(:index_solr)
      end
  end
end
