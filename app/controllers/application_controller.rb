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

  # 元データのpostにユーザ名、プロフィール画像、いいねしているかどうかのステータスを加える
  def fetch_infos_from_post(post)
    # postをハッシュに変換
    post_hash = post.attributes
    user = User.find_by(id: post.user_id)
    # そのpostのデータに紐付いたユーザ名、プロフィール画像を付け加えて返す
    post_hash.store("user_name", user.name)
    post_hash.store("img_src", user.image_name.url)
    # そのpostをログインユーザがいいねしていたら
    if Like.find_by(user_id: @current_user.id, post_id: post.id)
      post_hash.store("like_status", true)
    # そのpostをログインユーザがいいねしていなかったら
    else
      post_hash.store("like_status", false)
    end
    return post_hash
  end

  # ユーザのプロフィール画像のurlを取得する
  def fetch_img_src(user)
    user_hash = user.attributes
    user_hash.store("img_src", user.image_name.url)
    return user_hash
  end

  # そのユーザをログインユーザがフォローしているかどうかを判断する
  def is_follow?(user)
    if Follow.find_by(follower_id: @current_user, followee_id: user.id)
      return true
    else
      return false
    end
  end

end
