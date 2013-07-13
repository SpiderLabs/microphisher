Mongophisher::Application.routes.draw do
  # Root controller
  root to: 'home#index'

  # Resources
  resources :unknown_subjects do
    resources :data_sources do
      resource :status_updates
    end
  end

  # Home screen
  get 'home' => 'home#index'
  
  # OAuth actions
  get 'oauth/login' => 'oauth#login'
  get 'oauth/logout' => 'oauth#logout'
  get 'oauth/authorize' => 'oauth#authorize'  
end
