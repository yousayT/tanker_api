class Api::PostsController < ApplicationController
  before_action :authenticate_user
  before_action :check_user, only: :destroy

  # 新規投稿
  def create
    @post = Post.new(content: params[:content], user_id: @current_user.id)
    # フロントからタグの名前の配列が来ることを想定（例：　tag_list: ["tag1", "tag2", ... , "tagn"]）
    tag_names = params.permit(tag_list:[])
    if tag_names
      tag_names.each do |tag_name|
        @post.tag_list.add(tag_name)
      end
    end
    if @post.save
      render json: {
        post: @post
      }
    else
      render json: {
        status: 400,
        error_messages: @post.errors.full_messages
      }
    end
  end

  # 投稿の詳細
  def show
    @post = Post.find_by(id: params[:id])
    @user = User.find_by(id: @post.user_id)
    # 投稿そのものとその投稿に紐づいたユーザ情報、プロフィール画像のソース、ログインユーザがいいねしているかどうかのステータスを返す
    render json: {
      post: fetch_infos_from_post(@post)
    }
  end

  # 投稿の削除
  def destroy
    @post = Post.find_by(id: params[:id])
    @post.destroy
  end

  # 投稿をいいねする
  def like
    # Likesテーブルにuser_id, post_idのセット作成
    @like = Like.new(user_id: @current_user.id, post_id: params[:id])
    # いいね情報の保存に成功した時
    if @like.save
      # いいねカウントを1増やす
      @post = Post.find_by(id: params[:id])
      @post.likes_count += 1
      @post.save
      # いいね情報をpostの中に入れる
      post_hash = @post.attributes
      post_hash.store("like_status", true)
      render json: {
        post: post_hash,
        likes_count: @post.likes_count
      }
    # いいね情報の保存に失敗した時
    else
      render json: {
        status: 409,
        error_messages: @like.errors.full_messages
      }
    end
  end

  # いいねの解除
  def unlike
    # Likesテーブルのuser_id, post_idのセットを削除
    # 該当のいいね情報が見つかった時
    if @like = Like.find_by(user_id: @current_user.id, post_id: params[:id])
      @like.destroy
      # いいねカウントを1減らす
      @post = Post.find_by(id: params[:id])
      @post.likes_count -= 1
      @post.save
      # いいね情報をpostの中に入れる
      post_hash = @post.attributes
      post_hash.store("like_status", false)
      render json: {
        post: post_hash,
        likes_count: @post.likes_count
      }
    # 該当のいいね情報が見つからなかった時
    else
      render json: {
        status: 404
      }
    end
  end

  # ログインユーザ本人でしか行えない操作について本人かどうかをチェックする
  def check_user
    if Post.find_by(id: params[:id])&.user_id != @current_user.id
      render json:{
        status: 403
      }
    end
  end

end
