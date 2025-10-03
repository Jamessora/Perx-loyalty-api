class RewardIssuer
  # writes to ledger_entries with DB-backed idempotency (unique index on [user_id, key])

  def record_points!(user_id:, month_key:, points:)
    key = "points:#{month_key}"
    upsert!(user_id:, key:, entry_type: "points", metadata: { "points" => points })
  end

  def issue_reward!(user_id:, reward:, key:, reason:, at: Time.current)
    meta = { "reward" => reward.code, "reason" => reason, "issued_at" => at.iso8601 }
    upsert!(user_id:, key:, entry_type: "reward", metadata: meta)
  end

  private

  def upsert!(user_id:, key:, entry_type:, metadata:)
    LedgerEntry.upsert(
      { user_id:, key:, entry_type:, metadata:, created_at: Time.current, updated_at: Time.current },
      unique_by: :index_ledger_entries_user_key
    )
  end
end
