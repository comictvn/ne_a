require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    # Merging the new route for updating articles with the existing routes
    resources :articles, only: [] do
      get 'manage', on: :collection, to: 'articles#index'
      put ':id', to: 'articles#update' # New route added from the new code
    end

    # Existing routes from the existing code
    post '/auth/login', to: 'base#authenticate'
    post '/articles/drafts', to: 'articles#create_draft'
    post '/articles/:article_id/metadata', to: 'articles#add_metadata'
  end

  # Keeping the existing route outside of the namespace block
  put '/api/articles/:id/publish', to: 'articles#publish'
  # ... other routes ...
end
