class LedgerEntry < ApplicationRecord
  belongs_to :user
  enum :entry_type, { points: "points", reward: "reward" }, prefix: :as
end
