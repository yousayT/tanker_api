class PostsController < ApplicationController

  def create
    # puts @current_user
    #postmanチェック済み（2020/09/07）
    @post = Post.new(content: params[:content], user_id: @current_user.id)
    #フロントからタグの名前の配列が来ることを想定（例：　tag_name: ["tag1", "tag2", ... , "tagn"]）
    tag_names = params.permit(tag_name:[])
    tag_names[:tag_name].each do |tag_name|
      @post.tag_list.add(tag_name)
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

end
