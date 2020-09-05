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

  def protect_from_forgery
  end

end
