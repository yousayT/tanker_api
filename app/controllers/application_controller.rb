class ApplicationController < ActionController::API
  include ActionController::Helpers
  include ActionController::RequestForgeryProtection
  before_action :current_user
  helper_method :current_user

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    else
      puts 'No currentUser'
    end
  end

  def authenticate_user
    if @current_user == nil
      render json: {
        status: 401
        #status: 401を渡すだけでいいのだろうか？まだわかってない
      }
    end
  end

  def protect_from_forgery
  end

  def fetch_user_info_from_post(post)
    #postmanチェック済み（2020/09/11）
    # postをハッシュに変換
    post_hash = post.attributes
    user = User.find_by(id: post.user_id)
    # そのpostのデータに紐付いたユーザ名、プロフィール画像を付け加えて返す
    post_hash.store("user_name", user.name)
    post_hash.store("img_src", user.image_name.url)
    return post_hash
  end

  def is_follow?(user)
    if Follow.find_by(follower_id: user.id, followee_id: @current_user)
      return true
    else
      return false
    end
  end

end
