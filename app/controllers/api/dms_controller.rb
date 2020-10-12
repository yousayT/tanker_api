class Api::DmsController < ApplicationController
  before_action :authenticate_user
  before_action :check_user, only: :destroy

  # 過去にDMを送ったことのあるユーザの一覧と最も最近のDMの内容を返す
  def user_index
    has_contacted_user_ids = Dm.where(sender_id: @current_user.id).group(:receiver_id).pluck(:receiver_id)
    has_contacted_users = Array.new
    has_contacted_user_ids.each do |has_contacted_user_id|
      has_contacted_users.push(Dm.where(sender_id: @current_user.id, receiver_id: has_contacted_user_id)).order('created_at DESC').limit(1)
    end
    render json: {
      users: fetch_infos_from_dm(has_contacted_users)
    }
  end

  # あるユーザとのDMの内容を全て返す
  def dm_index
    dms = Dm.where(sender_id: @current_user.id, receiver_id: params[:receiver_id]).or(Dm.where(sender_id: params[:receiver_id], receiver_id: @current_user.id)).order('created_at DESC')
    molded_dms = Array.new
    # もしcurrent_userがDMの送信者ならtrueを、受信者ならfalseを加えてDMのid、内容、作成時とともに返す
    dms.each do |dm|
      dm_hash = dm.attributes
      if dm.sender_id == @current_user.id
        dm_hash.store("is_sender", true)
      else
        dm_hash.store("is_sender", false)
      end
      molded_dms.push(dm_hash)
    end
    render json:{
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
      render json: {
        status: 400,
        error_messages: dm.errors.full_messages
      }
    end
  end

  def destroy
    dm = Dm.find_by(id: params[:id])
    dm.destroy
  end

  # ログインユーザ本人でしか行えない操作について本人かどうかをチェックする
  def check_user
    if Dm.find_by(id: params[:id])&.sender_id != @current_user.id
      render json:{
        status: 403
      }
    end
  end

end
