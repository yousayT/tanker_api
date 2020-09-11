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
    #postmanチェック済み（2020/09/09）
    # そのユーザ（:id）をフォローしているフォロー情報を最近フォローした順に取得
    @follows = Follow.where(followee_id: params[:id]).order('created_at DESC')
    @followers = Array.new
    # フォロワーたちのユーザ情報を取得
    @follows.each do |follow|
      @followers.push(User.find_by(id: follow.follower_id))
    end
    # フォロワーたちの情報とフォロワー数を返す
    render json: {
      followers: @followers,
      follower_count: @followers.count
    }
  end

  def followee_index
    #postmanチェック済み（2020/09/09）
    # そのユーザ（:id）がフォローしているフォロー情報を最近フォローした順に取得
    @follows = Follow.where(follower_id: params[:id]).order('created_at DESC')
    @followees = Array.new
    # フォローされている人たちのユーザ情報を取得
    @follows.each do |follow|
      @followees.push(User.find_by(id: follow.followee_id))
    end
    # フォローされている人たちの情報とフォロー数を返す
    render json: {
      followees: @followees,
      followee_count: @followees.count
    }
  end

  def timeline
    #postmanチェック済み(2020/09/11)
    # ログインユーザがフォローしているユーザidを配列で取得
    @follows = Follow.where(follower_id: @current_user.id)
    @followee_ids = Array.new
    @follows.each do |follow|
      @followee_ids.push(follow.followee_id)
    end
    # フォローしているユーザidの配列にログインユーザのidを追加
    @followee_ids.push(@current_user.id)
    # IN句を使って投稿を配列で取得
    @posts = Post.where(created_at: Time.current.ago(3.month)..Time.current, user_id: @followee_ids).order('created_at DESC')
    # 各postにuser_nameを追加
    @posts_has_user_info = Array.new
    @posts.each do |post|
      @posts_has_user_info.push(fetch_user_info_from_post(post))
    end
    # user_nameの入ったpostを返す
    render json: {
      posts: @posts_has_user_info
    }
  end

end
