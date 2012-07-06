Salestrest::Application.routes.draw do
  namespace :sessions do
    resources :oauth, :only => [] do
      collection do
        get 'callback'
      end
    end
  end
  resources :pins
  resources :sobjects do
    collection do
      get 'pin/:id' => "sobject#pin", :as => "pin"
    end
  end
  resources :chatter, :only => [:create, :show]
  resources :dashboard, :only => [:index]
  root :to => "sobjects#show", :id => "Account"
end
