class Api::Admin::UsersController < ApplicationController
  before_action :check_admin

  # 全てのユーザの一覧を取得
  def index
    users = User.all
    render json: {
      users: users
    }
  end

  # アカウントを凍結させる
  def freeze
    user = User.find_by(id: params[:id])
    user.is_frozen = true
    user.save
  end

  # アカウントの凍結を解除する
  def thaw
    user = User.find_by(id: params[:id])
    user.is_frozen = false
    user.save
  end

end
