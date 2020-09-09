class UsersController < ApplicationController
  before_action :check_user, only: :update

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
      #いいねした投稿の一覧表示
      liked_posts: @liked_posts
    }
  end

  def update
    @current_user.update_attributes(user_params)
    # 変更前のパスワードが入力されていたら
    if params[:old_password]
      # かつそのパスワードが正しかったら
      if @current_user.authenticate(params[:old_password])
        # パスワードを変更
        @current_user.password = params[:new_password]
        @current_user.password_confirmation = params[:new_password_confirmation]
        # 新しいパスワードの保存に失敗した時
        if !@current_user.save
          render json:{
            status: 400,
            error_messages: @current_user.errors.full_messages
          }
        end
      # パスワードが正しくなかったら
      else
        render json:{
          status: 401
        }
      end
    # 変更前のパスワードが入力されていなかったら
    else
      # パスワード以外の情報を保存し、それに失敗したら
      if !@current_user.save
        render json:{
          status: 400,
          error_messages: @current_user.errors.full_messages
        }
      end
    end
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

  def check_user
    if params[:id] != @current_user.id
      render json:{
        status: 403
      }
  end

  private
  def user_params
    params.require(:user).permit(:name, :uid, :image_name, :profile, :password, :password_confirmation)
  end

end
