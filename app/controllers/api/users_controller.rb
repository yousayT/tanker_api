# frozen_string_literal: true

class Api::UsersController < ApplicationController
  before_action :authenticate_user, only: %i[show update logout destroy recommend]
  before_action :check_user, only: %i[update destroy]

  include CarrierwaveBase64Uploader

  # ユーザの新規作成
  def create
    @user = User.new(user_params)
    # @userの保存に成功したら
    response_bad_request(@user) unless @user.save

    # sessionにuser_idを入れてログイン状態にする
    session[:user_id] = @user.id
    # フロントにログインユーザのデータを返す
    render json: {
      user: @user
    }
  end

  # ユーザの詳細表示
  # ユーザ自身の情報の他に、そのユーザの投稿とそのユーザがいいねした投稿も返す
  def show
    # :idからユーザ情報を入手
    @user = User.find_by(id: params[:id])
    # そのユーザの投稿を全て取得し、各投稿にユーザ名とプロフィール画像、その投稿をいいねしているかどうかのステータスを追加
    @posts = Post.where(user_id: params[:id]).order('created_at DESC')
    @posts_has_infos = []
    @posts.each do |post|
      @posts_has_infos.push(fetch_infos_from_post(post))
    end
    @likes = Like.where(user_id: params[:id]).order('created_at DESC')
    # いいねした投稿を全て取得し、各投稿にユーザ名とプロフィール画像、その投稿をいいねしているかどうかのステータスを追加
    @liked_posts_has_infos = []
    @likes&.each do |like|
      @liked_posts_has_infos.push(fetch_infos_from_post(Post.find_by(id: like.post_id)))
    end
    # ユーザ情報、そのユーザの全投稿、そのユーザがいいねした全ての投稿、ユーザのid、そのユーザをフォローしているかどうかのステータス、そのユーザのフォロワー数及びフォロー数を返す
    render json: {
      user: fetch_img_src(@user),
      posts: @posts_has_infos,
      liked_posts: @liked_posts_has_infos,
      followee_id: @user.id,
      follow_status: follow?(@user.id),
      follower_count: @user.follower_count,
      follow_count: @user.followee_count
    }
  end

  # ユーザ情報の更新
  # パスワードの変更があるかないかで少し挙動が異なる
  def update
    # 画像の変更がなされていたら、base64にエンコードされた画像データに変換して保存
    if params[:user][:image_name].present?
      params[:user][:image_name] = base64_conversion(params[:user][:image_name], SecureRandom.uuid)
      @current_user.image_name = params[:user][:image_name]
      @current_user.save
    end
    # ここで予想されているパラメータは、"user": {"name": "hogehoge", "uid": "fugafuga", ...}の形
    # 変更前のパスワードが入力されていたら
    if params[:user][:old_password].present?
      # かつそのパスワードが正しかったら
      response_unauthorized unless @current_user.authenticate(params[:user][:old_password])
      # 新しいパスワードを含むユーザ情報の更新に成功した時
      response_bad_request(@current_user) unless @current_user.update(user_params)

      render json: {
        user: fetch_img_src(@current_user)
      }
    # 変更前のパスワードが入力されておらず、ユーザ情報の更新に成功した時
    elsif @current_user.update(user_params)
      render json: {
        user: fetch_img_src(@current_user)
      }
    # ユーザ情報の更新に失敗した時
    else
      response_bad_request(@current_user)
    end
  end

  # ユーザのログイン
  def login
    @user = User.find_by(uid: params[:uid])
    response_unauthorized unless @user&.authenticate(params[:password])
    session[:user_id] = @user.id
    render json: {
      user: fetch_img_src(@user)
    }
  end

  # ユーザのログアウト
  def logout
    session[:user_id] = nil
    @current_user = nil
  end

  # ユーザの退会
  def destroy
    session[:user_id] = nil
    @current_user.reset_counts
    @current_user.destroy
  end

  # フォロワーの多い順に最大６人のおすすめユーザを返す
  def recommend
    # フォロワーの多い順に多めにユーザを取得
    recommended_users = User.order('follower_count DESC').limit(30)
    unfollowed_reco_users = []
    i = 0
    recommended_users.each do |recommended_user|
      # おすすめユーザを最大６人まで取得する
      break unless i < 6

      # ログインユーザがそのユーザをまだフォローしていなかったらおすすめユーザリストに追加
      next if follow?(recommended_user.id)

      recommended_user_has_img_src = fetch_img_src(recommended_user)
      recommended_user_has_img_src.store('follow_status', false)
      recommended_user_has_follow_status = recommended_user_has_img_src
      unfollowed_reco_users.push(recommended_user_has_follow_status)
      i += 1
    end
    render json: {
      users: unfollowed_reco_users
    }
  end

  # ログインユーザ本人でしか行えない操作について本人かどうかをチェックする
  def check_user
    return unless params[:id].to_i != @current_user.id

    response_unauthorized
  end

  private

  def user_params
    params.require(:user).permit(:name, :uid, :profile, :password, :password_confirmation)
  end
end
