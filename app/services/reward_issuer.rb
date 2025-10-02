class RewardIssuer
  attr_reader :ledger
  def initialize
    @ledger = []
  end

  def record_points!(user_id:, month_key:, points:)
    @ledger << LedgerEntry.new(
      user_id:, type: :points, key: "points:#{month_key}", metadata: { points: points }
    )
    true
  end

  def issue_reward!(user_id:, reward:, key:, reason:)
    @ledger << LedgerEntry.new(
      user_id:, type: :reward, key:, metadata: { reward: reward.code, reason: reason }
    )
    true
  end
end
