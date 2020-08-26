class ApplicationController < ActionController::API
  before_action :set_current_user

  def set_current_user
    @current_user = User.find_by(token: params[:token])
  end


end
