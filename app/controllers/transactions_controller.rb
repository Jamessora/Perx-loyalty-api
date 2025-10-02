class TransactionsController < ApplicationController
  def create
    uid = Integer(params.require(:user_id))
    return render(json: { error: "user not found" }, status: :not_found) unless USERS[uid]

    tx = Transaction.new(
      user_id: uid,
      amount_cents: Integer(params.require(:amount_cents)),
      occurred_at: Time.parse(params.require(:occurred_at)),
      foreign: ActiveModel::Type::Boolean.new.cast(params[:foreign])
    )
    TXS[uid] << tx

    res = RULES.evaluate(user: USERS[uid], transactions: TXS[uid])
    month_key = Timebox.month_key(Time.now)
    ISSUER.record_points!(user_id: uid, month_key: month_key, points: res[:monthly_points][month_key].to_i)
    res[:eligible_rewards].each { |r| ISSUER.issue_reward!(user_id: uid, reward: r[:reward], key: r[:key], reason: r[:reason]) }

    render json: { ok: true, monthly_points: res[:monthly_points], newly_eligible: res[:eligible_rewards].map { |r| r[:reward].code } }
  end
end
