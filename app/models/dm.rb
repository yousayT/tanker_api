# frozen_string_literal: true

class Dm < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id

  validates :content, { presence: true, length: { maximum: 500 } }
  validates :sender_id, { presence: true }
  validates :receiver_id, {
    presence: true,
    numericality: { other_than: :sender_id, message: '自分へDMを送ることはできません' }
  }

  def self.sen_rec_r_get(sender_id, receiver_id, is_read)
    Dm.where(sender_id: sender_id, receiver_id: receiver_id, is_read: is_read)
  end

  def self.sen_rec_get(sender_id, receiver_id)
    Dm.where(sender_id: sender_id, receiver_id: receiver_id)
  end

  def self.sen_get(sender_id)
    Dm.where(sender_id: sender_id)
  end

  def self.rec_get(receiver_id)
    Dm.where(receiver_id: receiver_id)
  end

  def self.sen_or_rec_get(user_id)
    Dm.sen_get(user_id).or(Dm.rec_get(user_id)).order('created_at DESC')
  end

  def self.sen_rec_get_or(user_id1, user_id2)
    Dm.sen_rec_get(user_id1, user_id2).or(Dm.sen_rec_get(user_id2, user_id1)).order('created_at DESC')
  end
end
