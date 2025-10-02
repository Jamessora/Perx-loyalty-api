class PointsCalculator
  MODE = :threshold
  def initialize(base_per_100: 10, foreign_multiplier: 2)
    @base_per_100, @foreign_multiplier = base_per_100, foreign_multiplier
  end
  def points_for(t)
    base = ((t.amount_usd / 100.0).floor) * @base_per_100
    t.foreign ? base * @foreign_multiplier : base
  end
end
