class AddCapacityToClassBookings < ActiveRecord::Migration[8.1]
  def change
    # Set a default capacity of 20, which can be overridden in seeds or creation
    add_column :class_bookings, :capacity, :integer, default: 20, null: false 
  end
end
