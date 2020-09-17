Rails.application.routes.draw do
  namespace 'api' do
    post "users/create" => "users#create"
    get "users/:id" => "users#show"
    post "users/:id/update" => "users#update"
    post "login" => "users#login"
    post "logout" => "users#logout"
    post "users/:id/destroy" => "users#destroy"

    post "users/:id/follow" => "follows#create"
    post "users/:id/remove" => "follows#destroy"
    get "users/:id/follower" => "follows#follower_index"
    get "users/:id/followee" => "follows#followee_index"

    post "posts/create" => "posts#create"
    get "posts/timeline" => "follows#timeline"
    get "posts/:id" => "posts#show"
    post "posts/:id/destroy" => "posts#destroy"
    post "posts/:id/like" => "posts#like"
    post "posts/:id/unlike" => "posts#unlike"
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  end
end
