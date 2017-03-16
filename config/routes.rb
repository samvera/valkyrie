# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  mount Blacklight::Engine => '/'
  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  get '/catalog/parent/:parent_id/:id', to: 'catalog#show', as: :parent_solr_document

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :books, only: [:new, :create, :edit, :update, :destroy] do
    member do
      get '/append/book', action: :append, model: Book, as: :book_append
      get '/append/page', action: :append, model: Page, as: :page_append
      get :file_manager
    end
  end

  resources :pages, only: [:new, :create, :edit, :update, :destroy]
end
