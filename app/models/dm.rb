class Dm < ApplicationRecord
  belongs_to :sender, class_name: "User", foreign_key: :sender_id
  belongs_to :receiver, class_name: "User", foreign_key: :receiver_id

  validates :content, {presence: true, length: {maximum: 500}}
  validates :sender_id, {presence: true}
  validates :receiver_id, {
    presence: true,
    numericality: {other_than: :sender_id, message: "自分へDMを送ることはできません"}
  }
end
