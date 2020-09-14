class User < ApplicationRecord
  has_secure_token
  has_secure_password
  # 画像アップロード機能の追加
  mount_uploader :image_name, UserImageUploader

  # dependentの記述によって、
  # userが削除されると関連付いたposts, likes, followsも全て削除される
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :followers, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :followees, class_name: "Follow", foreign_key: "followee_id", dependent: :destroy
  has_many :following, through: :followers, source: :followed_user
  has_many :followed, through: :followees, source: :following_user

  validates :name, {presence: true, length: {maximum: 20}}
  # ユーザ情報更新の際にパスワード入力なしでパスワード以外の情報を更新できるようにするためallow_nil: trueを追加
  validates :password, {presence: true, length: {in: 6..25}, allow_nil: true}
  validates :uid, {presence: true, uniqueness: true, length: {in: 4..25}}
  validates :profile, {length: {maximum: 150}}
end
