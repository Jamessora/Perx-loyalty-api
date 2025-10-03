class CreateUsers < ActiveRecord::Migration[8.0]
  def change
       create_table :users do |t|
      t.string  :name,           null: false
      t.integer :birthday_month, null: false
      t.timestamps
    end
    add_check_constraint :users, "birthday_month BETWEEN 1 AND 12", name: "users_birthday_month_1_12"
  end
end
