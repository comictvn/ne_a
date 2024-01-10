require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Merging the new route into the existing namespace block
  namespace :api do
    post '/auth/login', to: 'base#authenticate'
    post '/articles/drafts', to: 'articles#create_draft'
    post '/articles/:article_id/metadata', to: 'articles#add_metadata' # Added the new route within the namespace
  end

  # Keeping the existing route outside of the namespace block
  put '/api/articles/:id/publish', to: 'articles#publish'
end
