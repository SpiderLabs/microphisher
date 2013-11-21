Mongophisher::Application.routes.draw do
  # Root controller
  root to: 'home#index'

  # Resources
  resources :unknown_subjects do
  	member do
  		get :export_profile
  	end
  	
    resources :data_sources do
      resources :status_updates
    end
    
    resources :profiles do
      # Collection routes refer to multiple resources
      collection do
        get :search
      end
      
      # Member routes refer to a resource instance
      member do
        get :input
        get :nlp_tree
        post :validate
        post :autocomplete
      end
    end
  end

  # Home screen
  get 'home' => 'home#index'
  
  # OAuth actions
  get 'oauth/login'     => 'oauth#login'
  get 'oauth/logout'    => 'oauth#logout'
  get 'oauth/authorize' => 'oauth#authorize'  
end
