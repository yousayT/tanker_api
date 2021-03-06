# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  # 画像アップロード機能の追加
  mount_uploader :image_name, UserImageUploader

  # dependentの記述によって、
  # userが削除されると関連付いたposts, likes, followsも全て削除される
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :followers, class_name: 'Follow', foreign_key: 'follower_id', dependent: :destroy
  has_many :followees, class_name: 'Follow', foreign_key: 'followee_id', dependent: :destroy
  has_many :following, through: :followers, source: :follower
  has_many :followed, through: :followees, source: :followee
  has_many :senders, class_name: 'Dm', foreign_key: 'sender_id', dependent: :destroy
  has_many :receivers, class_name: 'Dm', foreign_key: 'receiver_id', dependent: :destroy
  has_many :sending, through: :senders, source: :sender
  has_many :receiving, through: :receivers, source: :receiver

  validates :name, { presence: true, length: { maximum: 20 } }
  # ユーザ情報更新の際にパスワード入力なしでパスワード以外の情報を更新できるようにするためallow_nil: trueを追加
  validates :password, { presence: true, length: { in: 6..25 }, allow_nil: true }
  validates :uid, { presence: true, uniqueness: true, length: { in: 4..25 } }
  validates :profile, { length: { maximum: 150 } }

  def reset_counts
    liked_post_ids = Like.where(user_id: id).pluck(:post_id)
    liked_posts = Post.where(id: liked_post_ids)
    liked_posts.each do |liked_post|
      liked_post.likes_count -= 1
      liked_post.save
    end
    follower_ids = Follow.where(followee_id: id).pluck(:follower_id)
    followers = User.where(id: follower_ids)
    followers.each do |follower|
      follower.followee_count -= 1
      follower.save
    end
    followee_ids = Follow.where(follower_id: id).pluck(:followee_id)
    followees = User.where(id: followee_ids)
    followees.each do |followee|
      followee.follower_count -= 1
      followee.save
    end
  end
end
