class UsersController < ApplicationController
  def create
    id    = params[:id]
    bmon  = params[:birthday_month]
    name  = params[:name].presence || "User#{id}"

    return render json: { error: "id and birthday_month are required" }, status: :unprocessable_content unless id && bmon

    user = User.new(id: id, name: name, birthday_month: bmon)
    if user.save
      render json: { ok: true, user_id: user.id }, status: :created
    else
      render json: { error: user.errors.full_messages.to_sentence }, status: :unprocessable_content
    end
  end
end
