class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :price
      t.string :period
      t.text :features
      t.boolean :popular

      t.timestamps
    end
  end
end
