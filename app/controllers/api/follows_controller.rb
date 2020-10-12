class Api::FollowsController < ApplicationController
  before_action :authenticate_user

  # フォロー
  def create
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
    # フォロー情報の保存に失敗した時
    else
      render json:{
        status: 409,
        error_messages: @follow.errors.full_messages
      }
    end
  end

  # リムーブ（フォロー解除）
  def destroy
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

  # フォロワーの一覧
  def follower_index
    # そのユーザのフォロワーのidを最近フォローした順に取得
    follower_ids = Follow.where(followee_id: params[:id]).order('created_at DESC').pluck(:follower_id)
    # フォロワーたちのユーザ情報を取得
    followers = Array.new
    follower_ids.each do |follower_id|
      follower = fetch_img_src(User.find_by(id: follower_id))
      follower.store("follow_status", is_follow?(follower_id))
      followers.push(follower)
    end
    # フォロワーたちの情報とフォロワー数を返す
    render json: {
      followers: followers,
      follower_count: followers.count
    }
  end

  # フォローされた人の一覧
  def followee_index
    # そのユーザにフォローされたユーザのidを最近フォローされた順に取得
    followee_ids = Follow.where(follower_id: params[:id]).order('created_at DESC').pluck(:followee_id)
    # フォローされた人たちのユーザ情報を取得
    followees = Array.new
    followee_ids.each do |followee_id|
      followee = fetch_img_src(User.find_by(id: followee_id))
      followee.store("follow_status", is_follow?(followee_id))
      followees.push(followee)
    end
    # フォローされた人たちの情報とフォロー数を返す
    render json: {
      followees: followees,
      followee_count: followees.count
    }
  end

  # フォローした人と自身の3ヶ月以内の投稿を一覧表示
  def timeline
    # ログインユーザがフォローしているユーザidを配列で取得
    @followee_ids = Follow.where(follower_id: @current_user.id).pluck(:followee_id)
    # IN句を使って投稿を配列で取得
    @posts = Post.where(created_at: Time.current.ago(3.month)..Time.current, user_id: @followee_ids).order('created_at DESC')
    # 各postにユーザ名とプロフィール画像、ログインユーザがそのpostをいいねしているかどうかのステータスを追加
    @posts_has_infos = Array.new
    @posts.each do |post|
      @posts_has_infos.push(fetch_infos_from_post(post))
    end
    # ユーザ名、プロフィール画像、いいねしているかどうかのステータスが入ったpostを返す
    render json: {
      posts: @posts_has_infos
    }
  end

end
