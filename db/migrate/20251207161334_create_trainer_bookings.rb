class CreateTrainerBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :trainer_bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :trainer_name
      t.string :user_name
      t.string :user_email
      t.string :user_phone
      t.date :preferred_date
      t.text :goals_message
      t.string :status

      t.timestamps
    end
  end
end
