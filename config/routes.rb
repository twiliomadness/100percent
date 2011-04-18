Gotv::Application.routes.draw do
  get "sms_messages/incoming", :as => 'sms_request'
  post "voice_messages/incoming"
  post "voice_messages/recording"

  get "admin" => "admin#index", :as => :admin

  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#fail'

  namespace :admin do
    resources :county_clerks
    resources :users
    resources :voters do
      post 'send_text_message'
      post 'send_text_message_for_current_status'
    end
  end
  resources :voters
  
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :skip => [:registrations, :sessions] do
    # devise/registrations
    get 'signup'         => 'devise/registrations#new',     :as => :new_user_registration
    post 'signup'         => 'devise/registrations#create', :as => :user_registration
    get 'users/cancel'    => 'devise/registrations#cancel', :as => :cancel_user_registration
    get 'users/edit'      => 'devise/registrations#edit',   :as => :edit_user_registration
    put 'users'           => 'devise/registrations#update'
    delete 'users/cancel' => 'devise/registrations#destroy'

    # devise/sessions
    get 'signin'  => 'devise/sessions#new',     :as => :new_user_session
    post 'signin' => 'devise/sessions#create',  :as => :user_session
    get 'signout' => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  get "/namedob" => 'content#namedob', :as => :namedob
  get "/about" => 'content#about', :as => :about

  root :to => "content#index"
end

