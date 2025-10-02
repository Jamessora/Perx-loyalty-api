class CreateApiClients < ActiveRecord::Migration[8.0]
  def change
    create_table :api_clients do |t|
      t.string :name,  null: false
      t.string :token, null: false

      t.timestamps
    end
    add_index :api_clients, :token, unique: true
  end
end
