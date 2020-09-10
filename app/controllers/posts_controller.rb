class PostsController < ApplicationController
  before_action :authenticate_user
  before_action :check_user, only: :destroy

  def create
    # puts @current_user
    #postmanチェック済み（2020/09/07）
    @post = Post.new(content: params[:content], user_id: @current_user.id)
    #フロントからタグの名前の配列が来ることを想定（例：　tag_list: ["tag1", "tag2", ... , "tagn"]）
    tag_names = params.permit(tag_list:[])
    if tag_names
      tag_names[:tag_list].each do |tag_name|
        @post.tag_list.add(tag_name)
      end
    end
    @post.save
    render json: {
        post: @post
      }
  end

  def show
    #postmanチェック済み（2020/08/23）
    @post = Post.find_by(id: params[:id])
    render json: {
      post: @post
    }
  end


  def destroy
    @post = Post.find_by(id: params[:id])
    @post.destroy
  end

  def like
    # Likesテーブルにuser_id, post_idのセット作成
    @like = Like.new(user_id: @current_user.id, post_id: params[:id])
    @like.save
    # いいねカウントを1増やす
    @post = Post.find_by(id: params[:id])
    @post.likes_count += 1
    @post.save
    render json: {
      post: @post
    }
  end

  def unlike
    # Likesテーブルのuser_id, post_idのセットを削除
    @like = Like.find_by(user_id: @current_user.id, post_id: params[:id])
    @like.destroy
    # いいねカウントを1減らす
    @post = Post.find_by(id: params[:id])
    @post.likes_count -= 1
    @post.save
    render json: {
      post: @post
    }
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
