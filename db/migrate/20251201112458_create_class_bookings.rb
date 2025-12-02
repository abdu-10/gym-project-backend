class CreateClassBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :class_bookings do |t|
      t.string :name
      t.string :category
      t.string :image_url
      t.string :duration
      t.string :instructor
      t.string :time

      t.timestamps
    end
  end
end
