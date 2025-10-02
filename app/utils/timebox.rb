module Timebox
    def self.month_key(t = Time.now) = t.strftime("%Y-%m")
end