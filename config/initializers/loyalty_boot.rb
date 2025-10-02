USERS  = {}
TXS    = Hash.new { |h,k| h[k] = [] }
ISSUER = RewardIssuer.new
CALC   = PointsCalculator.new
RULES  = RewardRules.new(points_calculator: CALC)
