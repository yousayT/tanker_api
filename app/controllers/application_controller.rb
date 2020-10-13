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
    if @current_user == nil
      render json: {
        status: 401
      }
    end
  end

  def protect_from_forgery
  end

  # 元データのpostにユーザ名、プロフィール画像、いいねしているかどうかのステータスを加え、ハッシュにして返す
  def fetch_infos_from_post(post)
    # postをハッシュに変換
    post_hash = post.attributes
    user = User.find_by(id: post.user_id)
    # そのpostのデータに紐付いたユーザ名、プロフィール画像を付け加えて返す
    post_hash.store("user_name", user.name)
    post_hash.store("img_src", set_img_src(user))
    # そのpostをログインユーザがいいねしていたら
    if Like.find_by(user_id: @current_user.id, post_id: post.id)
      post_hash.store("like_status", true)
    # そのpostをログインユーザがいいねしていなかったら
    else
      post_hash.store("like_status", false)
    end
    return post_hash
  end

  # 元データのdmにユーザ名、プロフィール画像を加える
  def fetch_infos_from_dm(dm)
    # dmをハッシュに変換
    dm_hash = dm.attributes
    if dm.sender_id == @current_user.id
      user = User.find_by(id: dm.receiver_id)
    else
      user = User.find_by(id: dm.sender_id)
    end
    # そのdmのデータに紐付いたユーザ名、プロフィール画像を付け加えて返す
    dm_hash.store("user_name", user.name)
    dm_hash.store("img_src", set_img_src(user))
    return dm_hash
  end

  # ユーザのプロフィール画像のurlを取得して、ハッシュにして返す
  def fetch_img_src(user)
    user_hash = user.attributes
    user_hash.store("img_src", set_img_src(user))
    return user_hash
  end

  # そのユーザをログインユーザがフォローしているかどうかを判断する
  def is_follow?(user_id)
    if Follow.find_by(follower_id: @current_user, followee_id: user_id)
      return true
    else
      return false
    end
  end

  # 開発環境ならプロフィール画像のurlにlocalhost:3000を追加する
  def set_img_src(user)
    if Rails.env.development?
      return "http://localhost:3000" + user.image_name.url
    else
      return user.image_name.url
    end
  end

end
