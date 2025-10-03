class TransactionsController < ApplicationController
  def create
    user = User.find_by(id: params[:user_id])
    return render json: { error: "user not found" }, status: :not_found unless user

    txn = user.transactions.build(
      amount_cents: Integer(params[:amount_cents]),
      currency:     params[:currency].presence || "USD",
      occurred_at:  Time.iso8601(params[:occurred_at]),
      foreign:      ActiveModel::Type::Boolean.new.cast(params[:foreign])
    )

    unless txn.save
      return render json: { error: txn.errors.full_messages.to_sentence }, status: :unprocessable_content
    end

    # compute monthly points and rewards
    calc   = PointsCalculator.new
    issuer = RewardIssuer.new
    rules  = RewardRules.new(points_calculator: calc)

    # 1) recompute points for all user txns grouped by month
    grouped = user.transactions.group_by(&:month_key)
    monthly_points = grouped.transform_values do |txs|
      txs.sum { |t| calc.points_for(t) }
    end

    # persist this month's points entry
    month_key = txn.month_key
    issuer.record_points!(user_id: user.id, month_key:, points: monthly_points[month_key])

    # 2) apply reward rules and persist any new rewards
    result = rules.evaluate(user:, transactions: user.transactions.to_a)
    newly = []
    result[:eligible_rewards].each do |r|
      ok = issuer.issue_reward!(
        user_id: user.id, reward: r[:reward], key: r[:key], reason: r[:reason], at: r[:at]
      )
      newly << r[:reward].code if ok
    end

    render json: { ok: true, monthly_points:, newly_eligible: newly }, status: :created
  rescue ArgumentError
    render json: { error: "occurred_at must be ISO8601 and amount_cents must be integer" }, status: :unprocessable_content
  end
end
