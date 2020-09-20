Rails.application.routes.draw do
  namespace 'api' do
    post "login" => "users#login"
    post "logout" => "users#logout"
    resources :users, only: [:create, :show, :update, :destroy]

    post "users/:id/follow" => "follows#create"
    post "users/:id/remove" => "follows#destroy"
    get "users/:id/follower" => "follows#follower_index"
    get "users/:id/followee" => "follows#followee_index"

    get "posts/timeline" => "follows#timeline"
    resources :posts, only: [:create, :show, :destroy]
    post "posts/:id/like" => "posts#like"
    post "posts/:id/unlike" => "posts#unlike"

    resources :requests, only: [:create]

    namespace 'admin' do
      resources :users, only: [:index]
      resources :requests, only: [:index, :show, :destroy]
      post "requests/:id/switch" => "requests#switch"
    end
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  end
end
