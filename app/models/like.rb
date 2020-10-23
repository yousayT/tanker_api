# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, { presence: true }
  validates :post_id, {
    presence: true,
    # ユーザは一度までしか同じ投稿をいいねできない
    uniqueness: { scope: :user_id, message: 'その投稿は既にいいねされています' }
  }
end
