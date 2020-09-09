class FollowsController < ApplicationController
  before_action :authenticate_user

  def create
    #postmanチェック済み（2020/09/10）
    @follow = Follow.new(follower_id: @current_user.id, followee_id: params[:id])
    # current_userのフォロー数を1増やす
    @current_user.followee_count += 1
    @current_user.save
    # フォローされたユーザのフォロワー数を1増やす
    followee = User.find_by(id: params[:id])
    followee.follower_count += 1
    followee.save
    @follow.save
    render json: {
      user: @current_user
    }
  end

  def destroy
    #postmanチェック済み(2020/09/10)
    @follow = Follow.find_by(follower_id: @current_user.id, followee_id: params[:id])
    # current_userのフォロー数を1減らす
    @current_user.followee_count -= 1
    @current_user.save
    # フォローされていたユーザのフォロワー数を1減らす
    followee = User.find_by(id: params[:id])
    followee.follower_count -= 1
    followee.save
    @follow.destroy
    render json: {
      user: @current_user
    }
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

  def timeline
    #postmanチェック済み（2020/09/05)
    @follows = Follow.where(follower_id: @current_user.id)
    @followee_ids = Array.new
    @follows.each do |follow|
      @followee_ids.push(follow.followee_id)
    end
    @posts = Post.where(created_at: Time.current.ago(3.month)..Time.current, user_id: @followee_ids).order('created_at DESC')
    render json: {
      posts: @posts
    }
  end

end
