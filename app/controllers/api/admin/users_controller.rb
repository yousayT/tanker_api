class Api::Admin::UsersController < ApplicationController
  before_action :check_admin

  # 全てのユーザの一覧を取得
  def index
    users = User.all
    render json: {
      users: users
    }
  end

end
