class UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :update, :logout]
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
    #postmanチェック済み（2020/09/09）
    # ここで予想されているパラメータは、"user": {"name": "hogehoge", "uid": "fugafuga", ...}の形
    # 変更前のパスワードが入力されていたら
    if params[:user][:old_password].present?
      # かつそのパスワードが正しかったら
      if @current_user.authenticate(params[:user][:old_password])
        # 新しいパスワードを含むユーザ情報の更新に成功した時
        if @current_user.update_attributes(user_params)
          render json:{
            user: @current_user
          }
        # 新しいパスワードを含むユーザ情報の更新に失敗した時
        else
          render json:{
            status: 400,
            error_messages: @current_user.errors.full_messages
          }
        end
      # 入力されたパスワードが正しくなかったら
      else
        render json:{
          status: 401
        }
      end
    # 変更前のパスワードが入力されていなかったら
    else
      # ユーザ情報の更新に成功した時
      if @current_user.update_attributes(user_params)
        render json:{
          user: @current_user
        }
      # ユーザ情報の更新に失敗した時
      else
        render json: {
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
    if params[:id].to_i != @current_user.id
      render json:{
        status: 403
      }
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :uid, :image_name, :profile, :password, :password_confirmation)
  end

end
