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
    #postmanチェック済み（2020/09/11）
    @post = Post.find_by(id: params[:id])
    @user = User.find_by(id: @post.user_id)
    # 投稿そのものとその投稿に紐づいたユーザ情報、プロフィール画像のソースを返す
    render json: {
      post: @post,
      user: @user,
      image_src: @user.image_name.url
    }
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
