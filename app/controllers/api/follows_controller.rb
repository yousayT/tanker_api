class Api::FollowsController < ApplicationController
  before_action :authenticate_user

  def create
    #postmanチェック済み（2020/09/10）
    @follow = Follow.new(follower_id: @current_user.id, followee_id: params[:id])
    # フォロー情報の保存に成功した時
    if @follow.save
      # current_userのフォロー数を1増やす
      @current_user.followee_count += 1
      @current_user.save
      # フォローされたユーザのフォロワー数を1増やす
      followee = User.find_by(id: params[:id])
      followee.follower_count += 1
      followee.save
      # ログインユーザの情報と、フォローをしているというステータス、フォローされたユーザのフォロワー数を返す
      render json: {
        user: @current_user,
        follow_status: true,
        follower_count: followee.follower_count
      }
    else
      render json:{
        status: 409,
        error_messages: @follow.errors.full_messages
      }
    end
  end

  def destroy
    #postmanチェック済み(2020/09/10)
    # 該当のフォロー情報が見つかった時
    if @follow = Follow.find_by(follower_id: @current_user.id, followee_id: params[:id])
      # フォロー情報の削除に成功した時
      @follow.destroy
      # current_userのフォロー数を1減らす
      @current_user.followee_count -= 1
      @current_user.save
      # フォローされていたユーザのフォロワー数を1減らす
      followee = User.find_by(id: params[:id])
      followee.follower_count -= 1
      followee.save
      # ログインユーザの情報と、フォローをしていないというステータス、リムーブされたユーザのフォロワー数を返す
      render json: {
        user: @current_user,
        status: false,
        follower_count: followee.follower_count
      }
    # 該当のフォロー情報が見つからなかった時
    else
      render json:{
        status: 404
      }
    end
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
    # 各postにユーザ名とプロフィール画像、ログインユーザがそのpostをいいねしているかどうかのステータスを追加
    @posts_has_infos = Array.new
    @posts.each do |post|
      @posts_has_infos.push(fetch_infos_from_post(post))
    end
    # user_nameの入ったpostを返す
    render json: {
      posts: @posts_has_infos
    }
  end

end
