class User < ApplicationRecord
  has_secure_token
  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :likes
  # dependentの記述によって、
  # userが削除されると関連付いたpostsも全て削除される
  validates :name, {presence: true, length: {maximum: 20}}
  validates :password, {presence: true, length: {in: 6..25}}
  validates :uid, {presence: true, uniqueness: true, length: {in: 4..25}}
  validates :profile, {length: {maximum: 150}}
end
