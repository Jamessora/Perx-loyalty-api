puts "Seeding Sample Data"

# API client (auth)
client = ApiClient.find_or_create_by!(name: "SampleClient")
puts "API client token: #{client.token}"

# Users
u1 = User.find_or_create_by!(id: 101) { |u| u.name = "Jerico";  u.birthday_month = 10 }
u2 = User.find_or_create_by!(id: 102) { |u| u.name = "James";  u.birthday_month =  3 }

# Helper to add a transaction (points are auto-computed by Transaction callback)
def add_tx(user:, amount_cents:, occurred_at:, foreign: false, currency: "USD")
  user.transactions.create!(
    amount_cents: amount_cents,
    currency:     currency,
    occurred_at:  occurred_at,
    foreign:      foreign
  )
end

now = Time.current
last_month = (now.beginning_of_month - 1.day).change(day: 15).change(hour: 10)

# 3) Transactions for Jerico (reach 100 pts this month)
add_tx(user: u1, amount_cents: 300_00, occurred_at: now.change(day: 2, hour: 9),  foreign: true)  # 300 USD foreign  => 60 pts
add_tx(user: u1, amount_cents: 400_00, occurred_at: now.change(day: 2, hour: 11), foreign: false) # 400 USD domestic => 40 pts  => total 100

# 4) Transactions for James (split across months, should *not* trigger 100+ Reward this month)
add_tx(user: u2, amount_cents: 300_00, occurred_at: last_month,            foreign: true)  # 60 pts last month
add_tx(user: u2, amount_cents: 300_00, occurred_at: now.change(day: 5),    foreign: false) # 30 pts this month

# 5) Write monthly points + rewards into the ledger for each user
calc   = PointsCalculator.new
issuer = RewardIssuer.new
rules  = RewardRules.new(points_calculator: calc)

[ u1, u2 ].each do |user|
  # monthly points from persisted transaction points
  month_groups = user.transactions
    .pluck(:occurred_at, :points)
    .group_by { |(ts, _)| ts.in_time_zone.strftime("%Y-%m") }
    .transform_values { |rows| rows.sum { |(_, p)| p.to_i } }

  # persist an entry for the current month
  month_key = Timebox.month_key(Time.current)
  if month_groups[month_key].to_i > 0
    issuer.record_points!(user_id: user.id, month_key: month_key, points: month_groups[month_key])
  end

  # issue rewards
  res = rules.evaluate(user: user, transactions: user.transactions.to_a)
  res[:eligible_rewards].each do |r|
    issuer.issue_reward!(user_id: user.id, reward: r[:reward], key: r[:key], reason: r[:reason], at: r[:at])
  end
end

puts "Seed complete."
