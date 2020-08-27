class UsersController < ApplicationController

  def create
    #あとでuser_paramsに変える
    @user = User.new(uid: params[:uid],name: params[:name], password: params[:password], password_confirmation: params[:password_confirmation])
    @user.save
    session[:token] = @user.id
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
    @user = User.find_by(uid: params[:uid])
    if @user&.authenticate(params[:password])
      session[:user_id] = @user.id
      puts 'yaaaaaaay'
      puts session[:user_id]
      #ここまで出力される=sessionにちゃんと入ってる
      render json: {
        user: @user
      }
    else
      render json: {
        status: 401
      }
    end
  end

  # def login
  #   @user = User.find_by(uid: params[:uid], password: params[:password])
  #   if @user
  #     @current_user = @user.id
  #     render json: {
  #       user: @user,
  #       token: @user.token
  #     }
  #   else
  #     render status: 401
  #   end
  # end

  def logout
    session[:user_id] = nil
    @current_user = nil
  end

  private
  def user_params
    params.require(:user).permit(:name, :uid, :password, :password_confirmation)
  end

end
