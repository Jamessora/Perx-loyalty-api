class User < ApplicationRecord
  has_many :transactions, dependent: :destroy
  has_many :ledger_entries, dependent: :destroy

  validates :birthday_month, inclusion: { in: 1..12 }
  validates :name, presence: true
end
