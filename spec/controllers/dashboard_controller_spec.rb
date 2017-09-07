# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe "GET #index" do
    let(:user_query) { ["collection", "work1", "work2"] }
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:documents)).to eq(user_query)
    end
  end
end
