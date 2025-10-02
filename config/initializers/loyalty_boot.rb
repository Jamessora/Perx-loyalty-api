require Rails.root.join("app/models/reward")
require Rails.root.join("app/models/user")
require Rails.root.join("app/models/transaction")
require Rails.root.join("app/models/ledger_entry")

require Rails.root.join("app/utils/timebox")
require Rails.root.join("app/services/points_calculator")
require Rails.root.join("app/services/reward_issuer")
require Rails.root.join("app/services/reward_rules")

USERS  = {}
TXS    = Hash.new { |h,k| h[k] = [] }
ISSUER = RewardIssuer.new
CALC   = PointsCalculator.new
RULES  = RewardRules.new(points_calculator: CALC)
