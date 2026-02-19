class AddTrainerIdAndPreferredTimeToTrainerBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :trainer_bookings, :trainer_id, :integer
    add_column :trainer_bookings, :preferred_time, :time
    add_foreign_key :trainer_bookings, :trainers, column: :trainer_id
  end
end
