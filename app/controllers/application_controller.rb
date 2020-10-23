# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Helpers
  include ActionController::RequestForgeryProtection
  before_action :current_user
  helper_method :current_user

  # ログインユーザを設置
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    else
      puts 'No currentUser'
    end
  end

  # ログインしているかどうかをチェックする
  def authenticate_user
    return unless @current_user.nil?

    render json: {
      status: 401
    }
  end

  # 元データのpostにユーザ名、プロフィール画像、いいねしているかどうかのステータスを加え、ハッシュにして返す
  def fetch_infos_from_post(post)
    # postをハッシュに変換
    post_hash = post.attributes
    user = User.find_by(id: post.user_id)
    # そのpostのデータに紐付いたユーザ名、プロフィール画像を付け加えて返す
    post_hash.store('user_name', user.name)
    post_hash.store('img_src', img_src(user))
    # そのpostをログインユーザがいいねしていたら
    if Like.find_by(user_id: @current_user.id, post_id: post.id)
      post_hash.store('like_status', true)
    # そのpostをログインユーザがいいねしていなかったら
    else
      post_hash.store('like_status', false)
    end
    post_hash
  end

  # 元データのdmにユーザ名、プロフィール画像を加える
  def fetch_infos_from_dm(dm)
    # dmをハッシュに変換
    dm_hash = dm.attributes
    user = if dm.sender_id == @current_user.id
             User.find_by(id: dm.receiver_id)
           else
             User.find_by(id: dm.sender_id)
           end
    # そのdmのデータに紐付いたユーザ名、プロフィール画像を付け加えて返す
    dm_hash.store('user_name', user.name)
    dm_hash.store('img_src', img_src(user))
    dm_hash
  end

  # ユーザのプロフィール画像のurlを取得して、ハッシュにして返す
  def fetch_img_src(user)
    user_hash = user.attributes
    user_hash.store('img_src', img_src(user))
    user_hash
  end

  # そのユーザをログインユーザがフォローしているかどうかを判断する
  def follow?(user_id)
    return true if Follow.find_by(follower_id: @current_user, followee_id: user_id)

    false
  end

  # 開発環境ならプロフィール画像のurlにlocalhost:3000を追加する
  def img_src(user)
    return "http://localhost:3000#{user.image_name.url}" if Rails.env.development?

    user.image_name.url
  end
end
