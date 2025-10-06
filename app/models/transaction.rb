class Transaction < ApplicationRecord
  belongs_to :user

  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :occurred_at,  presence: true
  validates :currency,     presence: true

  before_validation :compute_points, on: :create

  def amount_usd  = amount_cents.to_f / 100.0
  def month_key   = occurred_at.in_time_zone.strftime("%Y-%m")

  private

  def compute_points
    self.points = PointsCalculator.new.points_for(self)
  end
end
