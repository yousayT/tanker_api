class Api::UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :update, :logout, :destroy, :recommend]
  before_action :check_user, only: [:update, :destroy]

  # ユーザの新規作成
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

  # ユーザの詳細表示
  # ユーザ自身の情報の他に、そのユーザの投稿とそのユーザがいいねした投稿も返す
  def show
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

  # ユーザ情報の更新
  # パスワードの変更があるかないかで少し挙動が異なる
  def update
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

  # ユーザのログイン
  def login
    @user = User.find_by(uid: params[:uid])
    if @user&.authenticate(params[:password])
      session[:user_id] = @user.id
      puts session[:user_id]
      render json: {
        user: @user
      }
    else
      render json: {
        status: 401
      }
    end
  end

  # ユーザのログアウト
  def logout
    session[:user_id] = nil
    @current_user = nil
  end

  # ユーザの退会
  def destroy
    session[:user_id] = nil
    @current_user.destroy
  end

  # フォロワーの多い順に最大６人のおすすめユーザを返す
  def recommend
    # フォロワーの多い順に多めにユーザを取得
    recommended_users = User.order('follower_count DESC').limit(30)
    unfollowed_reco_users = Array.new
    i = 0
    recommended_users.each do |recommended_user|
      # おすすめユーザを最大６人まで取得する
      if i < 6
        # ログインユーザがそのユーザをまだフォローしていなかったらおすすめユーザリストに追加
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

  # ログインユーザ本人でしか行えない操作について本人かどうかをチェックする
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
