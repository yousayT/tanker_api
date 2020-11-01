# frozen_string_literal: true

class Api::DmsController < ApplicationController
  before_action :authenticate_user
  before_action :check_user, only: :destroy

  # 過去にDMを送ったことのあるユーザの一覧と最も最近のDMの内容、未読数を返す
  def user_index
    user_ids = Dm.sen_or_rec_get(@current_user.id).pluck(:sender_id, :receiver_id)
    contact_user_ids = []
    user_ids.each do |sender_id, receiver_id|
      if sender_id == @current_user.id
        contact_user_ids.push(receiver_id)
      else
        contact_user_ids.push(sender_id)
      end
    end
    contact_user_ids.uniq!
    contact_users = []
    contact_user_ids.each do |contact_user_id|
      contact_user = fetch_infos_from_dm(Dm.sen_rec_get_or(@current_user.id, contact_user_id).limit(1)[0])
      unread_count = Dm.sen_rec_r_get(@current_user.id, contact_user_id, false).count
      contact_user.store('unread_count', unread_count)
      contact_users.push(contact_user)
    end
    render json: {
      users: contact_users
    }
  end

  # あるユーザとのDMの内容を送信者を明らかにして返し、全ての未読を既読にする
  def dm_index
    dms = Dm.sen_rec_get_or(@current_user.id, params[:receiver_id])
    unread_dms = Dm.sen_rec_r_get(params[:receiver_id], @current_user.id, false)
    unread_dms.each do |unread_dm|
      unread_dm.is_read = true
      unread_dm.save
    end
    molded_dms = []
    # もしcurrent_userがDMの送信者ならtrueを、受信者ならfalseを加えてDMのid、内容、作成時とともに返す
    dms.each do |dm|
      dm_hash = dm.attributes
      if dm.sender_id == @current_user.id
        dm_hash.store('is_sender', true)
      else
        dm_hash.store('is_sender', false)
      end
      molded_dms.push(dm_hash)
    end
    render json: {
      dms: molded_dms
    }
  end

  # DMの作成
  def create
    dm = Dm.new(sender_id: @current_user.id, receiver_id: params[:receiver_id], content: params[:content])
    if dm.save
      render json: {
        dm: dm
      }
    else
      response_bad_request(dm)
    end
  end

  def destroy
    dm = Dm.find_by(id: params[:id])
    dm.destroy
  end

  # ログインユーザ本人でしか行えない操作について本人かどうかをチェックする
  def check_user
    return unless Dm.find_by(id: params[:id])&.sender_id != @current_user.id

    response_unauthorized
  end
end
