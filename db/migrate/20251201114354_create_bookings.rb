class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      # Links the booking to a user and a class
      t.references :user, null: false, foreign_key: true
      t.references :class_booking, null: false, foreign_key: true

      t.timestamps
    end
    
    # CRITICAL: Ensures a user can only book the same class once
    add_index :bookings, [:user_id, :class_booking_id], unique: true
  end
end