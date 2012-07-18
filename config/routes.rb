Salestrest::Application.routes.draw do
  namespace :sessions do
    resources :oauth, :only => [] do
      collection do
        get 'callback'
      end
    end
    get :destroy
  end
  resources :pins
  resources :sobjects do
    collection do
      post 'pin/:id' => "sobjects#pin", :as => "pin"
      delete 'pin/:id' => "sobjects#unpin", :as => "pin"
    end
  end
  
  
  
  resources :chatter, :only => [:create, :show]
  resources :dashboard, :only => [:index]
  root :to => "sobjects#show", :id => "___Pinned"
end
