# frozen_string_literal: true
class DashboardController < ApplicationController
  def index
    @documents = DashboardService.find_by(current_user)
  end
end
