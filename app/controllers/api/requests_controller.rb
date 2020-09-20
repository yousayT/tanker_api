class Api::RequestsController < ApplicationController
  before_action :authenticate_user

  def create
    requests = Request.new(title: params[:title], content: params[:content], user_id: @current_user.id)
    if !requests.save
      render json: {
        status: 400,
        error_messages: requests.errors.full_messages
      }
    end
  end
end
