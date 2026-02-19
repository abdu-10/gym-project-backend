class CreateTrainers < ActiveRecord::Migration[8.1]
  def change
    create_table :trainers do |t|
      t.string :name
      t.string :role
      t.text :bio
      t.string :image
      t.string :instagram
      t.string :facebook
      t.string :twitter

      t.timestamps
    end
  end
end
