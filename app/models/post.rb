class Post < ApplicationRecord
  # タグ機能の追加
  acts_as_taggable

  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :users, through: :likes

  validates :content, {
    presence: true,
    length: {maximum: 50}
  }
  validates :user_id, {presence: true}
end
