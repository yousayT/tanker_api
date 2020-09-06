Rails.application.routes.draw do

    post "users/create" => "users#create"
    get "users/:id" => "users#show"
    post "login" => "users#login"
    post "logout" => "users#logout"

    post "users/:id/follow" => "follows#create"
    post "users/:id/remove" => "follows#destroy"
    get "users/:id/follower" => "follows#follower_index"
    get "users/:id/followee" => "follows#followee_index"

    get "posts/new" => "posts#new"
    post "posts/create" => "posts#create"
    get "posts/:id" => "posts#show"
    get "posts/:id/edit" => "posts#edit"
    post "posts/:id/update" => "posts#update"
    post "posts/:id/destroy" => "posts#destroy"
    post "posts/:id/like" => "posts#like"
    get "posts/timeline" => "follows#timeline"
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
