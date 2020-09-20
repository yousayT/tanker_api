class Api::Admin::RequestsController < ApplicationController
  before_action :check_admin

  # ユーザからのお問い合わせを既読と未読に分けて一覧表示
  def index
    unread_requests = Request.where(is_read: false).order('created_at DESC')
    read_requests = Request.where(is_read: true).order('created_at DESC')
    render json: {
      unread_requests: unread_requests,
      read_requests: read_requests
    }
  end

  # ユーザからのお問い合わせを詳細表示
  def show
    request = Request.find_by(id: params[:id])
    render json: {
      request: request
    }
  end

  # お問い合わせを既読または未読にする
  def switch
    request = Request.find_by(id: params[:id])
    request.is_read = !request.is_read
    request.save
    render json: {
      request: request
    }
  end

end
