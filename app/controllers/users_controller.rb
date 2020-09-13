class UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :update, :logout]
  before_action :check_user, only: :update

  def create
    @user = User.new(user_params)
    # @userの保存に成功したら
    if @user.save
      # sessionにuser_idを入れてログイン状態にする
      session[:user_id] = @user.id
      # フロントにログインユーザのデータを返す
      render json: {
        user: @user,
        token: @user.token
      }
    # @userの保存に失敗したら
    else
      # HTTPステータスコード400を返して、バリデーションに弾かれていた場合その内容も返す
      render json: {
        status: 400,
        error_messages: @user.errors.full_messages
      }
    end
  end

  def show
    #postmanチェック済み（2020/09/11）
    # :idからユーザ情報を入手
    @user = User.find_by(id: params[:id])
    # そのユーザの投稿を全て取得し、各投稿にユーザ名とプロフィール画像を紐付け
    @posts = Post.where(user_id: params[:id]).order('created_at DESC')
    @posts_has_user_info = Array.new
    @posts.each do |post|
      @posts_has_user_info.push(fetch_user_info_from_post(post))
    end
    @likes = Like.where(user_id: params[:id]).order('created_at DESC')
    # そのユーザがいいねをしていた場合、いいねした投稿を全て取得し、各投稿にユーザ名とプロフィール画像を紐付け
    if (@likes)
      @liked_posts_has_user_info = Array.new
      @likes.each do |like|
        @liked_posts_has_user_info.push(fetch_user_info_from_post(Post.find_by(id: like.post_id)))
      end
    # いいねをしていなかった場合、nilを返す
    else
      @liked_posts = nil
    end
    # ユーザ情報、そのユーザの全投稿、そのユーザがいいねした全ての投稿を返す
    render json: {
    #(このtokenはそのうち消すかも)
    token: @user.token,
    followee_id: params[:id],
    follow_status: is_follow?(@user),
    user: @user,
    posts: @posts_has_user_info,
    #いいねした投稿の一覧表示
    liked_posts: @liked_posts_has_user_info
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
