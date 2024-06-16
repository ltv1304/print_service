Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :tasks
  resources :template_tasks
  resources :templates

  namespace :api, :defaults => { :format => 'json' } do
    namespace :v1 do
      resources :tasks, param: :ticket  
      resources :template_tasks
      resources :templates
      post 'document', to: 'documents#load'
    end
  end
end