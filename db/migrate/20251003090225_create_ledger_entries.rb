class CreateLedgerEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :ledger_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :entry_type, null: false
      t.string  :key,        null: false
      t.json    :metadata,   null: false, default: {}
      t.timestamps
    end
    add_index :ledger_entries, [:user_id, :key], unique: true, name: "index_ledger_entries_user_key"
    add_index :ledger_entries, [:user_id, :created_at]
  end
end
