class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user,        null: false, foreign_key: true
      t.integer    :amount_cents, null: false
      t.string     :currency,     null: false, default: "USD"
      t.datetime   :occurred_at,  null: false
      t.boolean    :foreign,      null: false, default: false
      t.timestamps
    end
    add_index :transactions, [:user_id, :occurred_at]
  end
end
