class UsersController < ApplicationController
  def create
    unless params.key?(:id) && params.key?(:birthday_month)
      return render json: { error: "id and birthday_month are required" }, status: :unprocessable_entity
    end

    id = Integer(params[:id]) rescue nil
    birthday_month = Integer(params[:birthday_month]) rescue nil
    unless id && birthday_month
      return render json: { error: "id and birthday_month must be integers" }, status: :unprocessable_entity
    end

    unless (1..12).cover?(birthday_month)
      return render json: { error: "birthday_month must be 1..12" }, status: :unprocessable_entity
    end

    name = params[:name].presence || "User#{id}"
    USERS[id] = User.new(id:, name:, birthday_month: birthday_month)
    render json: { ok: true, user_id: id }, status: :created
  end
end
