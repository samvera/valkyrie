# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PagesController do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    sign_in user if user
  end
  describe "GET /pages/new" do
    it "renders a form with a new page" do
      get :new

      expect(response).to be_success
    end
  end

  describe "CREATE /page" do
    it "creates a new page" do
      post :create, params: { page: { title: ["Test"] } }

      expect(response).to be_redirect
    end
  end
end
