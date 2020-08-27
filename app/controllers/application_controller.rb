class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :auth

  # def set_current_user
  #   @current_user = User.find_by(token: params[:token])
  # end

  # auth_tokenか401を返却する。
  # このアクションをapp_controllerで実行しているので、グローバルに適用される。
  def auth
    auth_token || render(json: { error: :unauthorized }, status: 401)
  end

  # token, optionsの入ったブロックを渡してtokenをチェック。
  # tokenでuserを検索してcurrent_userを設定し、current_userを返却
  def auth_token
    authenticate_with_http_token do |token, options|
      @current_user = User.find_by(token: token)
      !!@current_user
    end
  end

end
