class FixTrainerBookingsForeignKey < ActiveRecord::Migration[8.1]
  def change
    # Remove the incorrect foreign key that points trainer_id to users
    remove_foreign_key :trainer_bookings, column: :trainer_id

    # Add the correct foreign key that points trainer_id to trainers
    add_foreign_key :trainer_bookings, :trainers, column: :trainer_id
  end
end
