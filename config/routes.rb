Gotv::Application.routes.draw do
  get "sms_messages/incoming"

  devise_for :users

  get "welcome/index"
  root :to => "welcome#index"
end
