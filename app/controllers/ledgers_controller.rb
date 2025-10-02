class LedgersController < ApplicationController
  def show
    uid = params[:user_id].to_i
    entries = ISSUER.ledger.select { |e| e.user_id == uid }.map do |e|
      { type: e.type, key: e.key, metadata: e.metadata, created_at: e.created_at }
    end
    render json: { user_id: uid, ledger: entries }
  end
end
