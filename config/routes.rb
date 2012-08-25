Gotv::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, ActiveAdmin::Devise.config

  get "sms_messages/incoming", :as => 'sms_request'
  post "voice_messages/incoming"
  post "voice_messages/recording"
  get "voice_messages/incoming"

  get "admin" => "admin#index", :as => :admin

  namespace :admin do
    resources :county_clerks
    resources :users
    resources :voters do
      post 'send_text_message'
      post 'send_text_message_for_current_status'
    end
  end
  resources :voters
  resources :web_voters
  resources :conferences
  match 'conferences/:id' => 'conferences#show', :via => [:get, :post]
  
  devise_for :users, :skip => [:registrations, :sessions] do
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

  get "/about" => 'content#about', :as => :about
  get "/contact" => 'content#contact', :as => :contact
  get "/support" => 'content#support', :as => :support
  get "/how_works" => 'content#how_works', :as => :how_works
  get "/dashboard" => 'dashboard#index', :as => :dashboard
  get "/voter" => 'web_voters#new', :as => :voter_signup
  post "/voter" => 'web_voters#create'
  get "/update_info" => 'web_voters#update_voting_info', :as => :update_voter_info
  get "/voter/address_lookup" => 'voters#address_lookup'

  root :to => "content#index"
end

