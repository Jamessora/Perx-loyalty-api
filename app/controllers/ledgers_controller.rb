class LedgersController < ApplicationController
  def show
    user = User.find_by(id: params[:user_id])
    return render json: { error: "user not found" }, status: :not_found unless user

    entries = user.ledger_entries.order(:created_at).map do |e|
      { type: e.entry_type, key: e.key, metadata: e.metadata, created_at: e.created_at.iso8601 }
    end

    render json: { user_id: user.id, ledger: entries }
  end
end
