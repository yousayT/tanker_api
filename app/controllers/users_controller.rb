class UsersController < ApplicationController
  skip_before_action :set_current_user, [:login], raise: false

  def create
    @user = User.new(name: params[:name], password: params[:password])
    @user.save
    # あとでPost一覧に指定　→　redirect_to("/users/#{@user.id}")
    session[:user_id] = @user.id
    @current_user = @user
    render json: {
      user: @user,
      token: @user.token
    }
  end

  def show
    #postmanチェック済み（2020/08/23）
    @user = User.find_by(id: params[:id])
    @posts = Post.where(user_id: params[:id]).order(created_at: :desc)
    @likes = Like.where(user_id: params[:id]).order(created_at: :desc)
    if (@likes)
      @liked_posts = Array.new
      @likes.each do |like|
        @liked_posts.push(Post.find_by(id: like.post_id))
      end
    else
      @liked_posts = nil
    end
      render json: {
      user: @user,
      token: @user.token,
      posts: @posts,
      liked_posts: @liked_posts #いいねした投稿の一覧表示
    }
  end


  def login
    @user = User.find_by(uid: params[:uid], password: params[:password])
    if @user
      @current_user = @user.id
      render json: {
        user: @user,
        token: @user.token
      }
    else
      render status: 401
    end
  end

  def logout
    session[:user_id] = nil
  end

end
