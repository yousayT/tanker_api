class PostsController < ApplicationController
  before_action :authenticate_user
  before_action :check_user, only: :destroy

  def create
    puts @current_user
    @post = Post.new(content: params[:content], user_id: @current_user.id)
    @post.save
    render json: @post
  end

  def show
    #postmanチェック済み（2020/08/23）
    @post = Post.find_by(id: params[:id])
    render json: {
      post: @post
    }
  end

  def edit
    @post = Post.find_by(id: params[:id])
    render json: @post
  end

  def update
    @post = Post.find_by(id: params[:id])
    @post.content = params[:content]
    @post.save
  end

  def destroy
    @post = Post.find_by(id: params[:id])
    @post.destroy
  end

  def like
    @post = Post.find_by(id: params[:post_id])
    @post.likes_count = params[likes_count]
    @post.save
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
