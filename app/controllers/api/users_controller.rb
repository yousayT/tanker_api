class Api::UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :update, :logout, :destroy, :recommend]
  before_action :check_user, only: [:update, :destroy]

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
    #postmanチェック済み（2020/09/20）
    # :idからユーザ情報を入手
    @user = User.find_by(id: params[:id])
    # そのユーザの投稿を全て取得し、各投稿にユーザ名とプロフィール画像、その投稿をいいねしているかどうかのステータスを追加
    @posts = Post.where(user_id: params[:id]).order('created_at DESC')
    @posts_has_infos = Array.new
    @posts.each do |post|
      @posts_has_infos.push(fetch_infos_from_post(post))
    end
    @likes = Like.where(user_id: params[:id]).order('created_at DESC')
    # そのユーザがいいねをしていた場合、いいねした投稿を全て取得し、各投稿にユーザ名とプロフィール画像、その投稿をいいねしているかどうかのステータスを追加
    if (@likes)
      @liked_posts_has_infos = Array.new
      @likes.each do |like|
        @liked_posts_has_infos.push(fetch_infos_from_post(Post.find_by(id: like.post_id)))
      end
    # いいねをしていなかった場合、nilを返す
    else
      @liked_posts = nil
    end
    # ユーザ情報、そのユーザの全投稿、そのユーザがいいねした全ての投稿、ユーザのid、そのユーザをフォローしているかどうかのステータス、そのユーザのフォロワー数及びフォロー数を返す
    render json: {
    #(このtokenはそのうち消すかも)
    token: @user.token,
    user: @user,
    posts: @posts_has_infos,
    liked_posts: @liked_posts_has_infos,
    followee_id: @user.id,
    follow_status: is_follow?(@user),
    follower_count: @user.follower_count,
    follow_count: @user.followee_count
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

  def logout
    session[:user_id] = nil
    @current_user = nil
  end

  def destroy
    session[:user_id] = nil
    liked_post_ids = Like.where(user_id: @current_user.id).pluck(:post_id)
    liked_posts = Post.where(id: liked_post_ids)
    liked_posts.each do |liked_post|
      liked_post.likes_count -= 1
      liked_post.save
    end
    follower_ids = Follow.where(followee_id: @current_user.id).pluck(:follower_id)
    followers = User.where(id: follower_ids)
    followers.each do |follower|
      follower.followee_count -= 1
      follower.save
    end
    followee_ids = Follow.where(follower_id: @current_user.id).pluck(:followee_id)
    followees = User.where(id: followee_ids)
    followees.each do |followee|
      followee.follower_count -= 1
      followee.save
    end
    @current_user.destroy
  end

  # フォロワーの多い順におすすめユーザを返す
  def recommend
    recommended_users = User.order(follower_count: 'DESC').limit(30)
    unfollowed_reco_users = Array.new
    i = 0
    recommended_users.each do |recommended_user|
      if i < 6
        if !(is_follow?(recommended_user))
          recommended_user_has_follow_status = add_follow_status(recommended_user)
          unfollowed_reco_users.push(recommended_user_has_follow_status)
          i += 1
        end
      else
        break
      end
    end
    render json:{
        users: unfollowed_reco_users
    }
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
