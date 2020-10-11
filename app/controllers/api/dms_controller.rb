class Api::DmsController < ApplicationController
  before_action :authenticate_user

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

  def dm_index

  end

  def create

  end

  def destroy

  end
end
