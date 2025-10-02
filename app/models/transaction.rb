class Transaction
    attr_reader :user_id, :amount_cents, :currency, :occurred_at, :foreign

    def initialize(user_id:, amount_cents:, currency: "USD", occurred_at:, foreign: false)
        @user_id = user_id
        @amount_cents = Integer(amount_cents)
        @currency = currency
        @occurred_at = occurred_at
        @foreign = !!foreign
    end

    def amount_usd = amount_cents / 100.0
    def month_key  = occurred_at.strftime("%Y-%m")
end
