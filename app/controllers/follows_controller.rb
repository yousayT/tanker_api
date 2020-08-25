class FollowsController < ApplicationController
  protect_from_forgery

  def create
    #postmanチェック済み（2020/08/24）
    @follow = Follow.new(follower_id: @current_user.id, followee_id: params[:id])
    @follow.save
    render json: @follow
  end

  def destroy
    #postmanチェック済み(2020/08/24)
    @follow = Follow.find_by(follower_id: @current_user.id, followee_id: params[:id])
    @follow.destroy
  end

  def follower_index
    #postmanチェック済み(2020/08/24)
    @follows = Follow.where(followee_id: params[:id]).order('created_at DESC')
    render json: @follows
  end

  def followee_index
    #postmanチェック済み(2020/08/24)
    @follows = Follow.where(follower_id: params[:id]).order('created_at DESC')
    render json: @follows
  end
end
