class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", foreign_key: :follower_id
  belongs_to :followee, class_name: "User", foreign_key: :followee_id

  validates :follower_id, {presence: true}
  validates :followee_id, {
    presence: true,
    # 同じフォロー情報は1つまでしか存在できない
    uniqueness: {scope: :follower_id, message: "そのユーザは既にフォローしています"},
    # フォロワーとフォローされている人のidは必ず異なる
    numericality: {other_than: :follower_id, message: "自分自身はフォローできません"}
  }
end
