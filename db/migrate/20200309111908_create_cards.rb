class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
    t.string :customer_id, null: false
    t.integer :user_id, null: false, foreign_key: true
    t.timestamps
    end
  end
end
