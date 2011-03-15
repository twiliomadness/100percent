Gotv::Application.routes.draw do
  devise_for :users

  get "welcome/index"
  root :to => "welcome#index"
end
