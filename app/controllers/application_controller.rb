class ApplicationController < ActionController::API
  include ActionController::Helpers
  before_action :current_user
  helper_method :current_user

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

end
