class TransactionsController < ApplicationController
  def create
    user = User.find_by(id: params[:user_id])
    return render json: { error: "user not found" }, status: :not_found unless user

    occurred_at = Time.iso8601(params[:occurred_at])
    
    txn = user.transactions.build(
      amount_cents: Integer(params[:amount_cents]),
      currency:     params[:currency].presence || "USD",
      occurred_at:  occurred_at,
      foreign:      ActiveModel::Type::Boolean.new.cast(params[:foreign])
    )

    ApplicationRecord.transaction do
      unless txn.save # points is set by Transaction#before_validation callback
        return render json: { error: txn.errors.full_messages.to_sentence }, status: :unprocessable_content
      end

      month_key = txn.month_key
      month_range = occurred_at.beginning_of_month..occurred_at.end_of_month

      # sum persisted points for THIS month
      points_this_month = user.transactions.where(occurred_at: month_range).sum(:points)

      # monthly breakdown for response: {"YYYY-MM"=>points, ...}
      monthly_points = user.transactions
        .order(:occurred_at)
        .pluck(:occurred_at, :points)
        .group_by { |(ts, _)| ts.in_time_zone.strftime("%Y-%m") }
        .transform_values { |rows| rows.sum { |(_, p)| p.to_i } }

      # Persist a monthly audit entry (if you keep ledger-based monthly points)
      RewardIssuer.new.record_points!(user_id: user.id, month_key:, points: points_this_month)

      # Evaluate rewards based on all txns
      calc   = PointsCalculator.new
      rules  = RewardRules.new(points_calculator: calc)
      newly  = []
      rules.evaluate(user:, transactions: user.transactions.to_a)[:eligible_rewards].each do |r|
        ok = RewardIssuer.new.issue_reward!(
          user_id: user.id, reward: r[:reward], key: r[:key], reason: r[:reason], at: r[:at]
        )
        newly << r[:reward].code if ok
      end

      return render json: { ok: true, monthly_points:, newly_eligible: newly }, status: :created
    end
  rescue ArgumentError
    render json: { error: "occurred_at must be ISO8601 and amount_cents must be integer" }, status: :unprocessable_content
  end
end
