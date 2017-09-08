# frozen_string_literal: true
class SongsController < ApplicationController
  include Valkyrie::ControllerConcerns::ModelControllerBehavior
  self.resource_class = Song

  def file_manager
    @record = change_set_class.new(find_resource(params[:id])).prepopulate!
    authorize! :file_manager, @record.resource
    @children = QueryService.find_members(resource: @record).map do |x|
      change_set_class.new(x).prepopulate!
    end.to_a
  end

  private

    def change_set_class
      DynamicChangeSetClass.new(params[:resource])
    end

    def resource_class
      resource_param || Song
    end

    def resource_params
      params[:song]
    end

    def resource_param
      return nil unless params[:resource]
      params[:resource].to_s.safe_constantize
    end
end
