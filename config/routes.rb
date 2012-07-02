Salestrest::Application.routes.draw do
  namespace :sessions do
    resources :oauth, :only => [] do
      collection do
        get 'callback'
      end
    end
  end
  resources :pins
  resources :sobjects
  resources :chatter, :only => [:create, :show]
  resources :dashboard, :only => [:index]
  root :to => "dashboard#index"
end
