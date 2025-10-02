class RewardRules
  FREE_COFFEE = Reward.new(code: "FREE_COFFEE", label: "Free Coffee").freeze
  FREE_MOVIE  = Reward.new(code: "FREE_MOVIE_TICKETS", label: "Free Movie Tickets").freeze

  def initialize(points_calculator:) = @points_calculator = points_calculator

  def evaluate(user:, transactions:)
    grouped = transactions.group_by(&:month_key)
    monthly_points = grouped.transform_values { |txs| txs.sum { |t| @points_calculator.points_for(t) } }

    now = Time.now
    month_key = Timebox.month_key(now)
    eligible = []

    if monthly_points[month_key].to_i >= 100
      eligible << { reward: FREE_COFFEE, key: "reward:coffee:#{month_key}", reason: "100+ points in #{month_key}", at: now }
    end
    if user.birthday_month == now.month
      eligible << { reward: FREE_COFFEE, key: "reward:coffee:birthday:#{now.strftime('%Y-%m')}", reason: "Birthday month", at: now }
    end
    unless transactions.empty?
      first_tx_time = transactions.min_by(&:occurred_at).occurred_at
      window_end = first_tx_time + 60*24*60*60
      spend = transactions.select { |t| t.occurred_at <= window_end }.sum(&:amount_usd)
      if spend > 1000.0
        eligible << { reward: FREE_MOVIE, key: "reward:movie:newuser:#{first_tx_time.to_date}", reason: "Spent > $1000 within 60 days of first transaction", at: now }
      end
    end

    { monthly_points:, eligible_rewards: eligible }
  end
end
