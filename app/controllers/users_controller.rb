class UsersController < ApplicationController
  def create
    id   = Integer(params.require(:id))
    name = params[:name].presence || "User#{id}"
    birthday_month = Integer(params.require(:birthday_month))
    USERS[id] = User.new(id: id, name: name, birthday_month: birthday_month)
    render json: { ok: true, user_id: id }, status: :created
  end
end
