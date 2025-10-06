class AddPointsToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :points, :integer, null: false, default: 0
    add_index  :transactions, :points
  end
end
