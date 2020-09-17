class Api::PostsController < ApplicationController
  before_action :authenticate_user
  before_action :check_user, only: :destroy

  def create
    # puts @current_user
    #postmanチェック済み（2020/09/07）
    @post = Post.new(content: params[:content], user_id: @current_user.id)
    #フロントからタグの名前の配列が来ることを想定（例：　tag_list: ["tag1", "tag2", ... , "tagn"]）
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

  def show
    #postmanチェック済み（2020/09/11）
    @post = Post.find_by(id: params[:id])
    @user = User.find_by(id: @post.user_id)
    # 投稿そのものとその投稿に紐づいたユーザ情報、プロフィール画像のソースを返す
    render json: {
      post: fetch_user_info_from_post(@post)
    }
  end


  def destroy
    @post = Post.find_by(id: params[:id])
    @post.destroy
  end

  def like
    # Likesテーブルにuser_id, post_idのセット作成
    @like = Like.new(user_id: @current_user.id, post_id: params[:id])
    # いいね情報の保存に成功した時
    if @like.save
      # いいねカウントを1増やす
      @post = Post.find_by(id: params[:id])
      @post.likes_count += 1
      @post.save
      render json: {
        post: @post
      }
    # いいね情報の保存に失敗した時
    else
      render json: {
        status: 409,
        error_messages: @like.errors.full_messages
      }
    end
  end

  def unlike
    # Likesテーブルのuser_id, post_idのセットを削除
    # 該当のいいね情報が見つかった時
    if @like = Like.find_by(user_id: @current_user.id, post_id: params[:id])
      @like.destroy
      # いいねカウントを1減らす
      @post = Post.find_by(id: params[:id])
      @post.likes_count -= 1
      @post.save
      render json: {
        post: @post
      }
    # 該当のいいね情報が見つからなかった時
    else
      render json: {
        status: 404
      }
    end
  end

  def check_user
    if Post.find_by(id: params[:id]).user_id != @current_user.id
      render json:{
        #これであってる？
        status: 403
      }
    end
  end

end
