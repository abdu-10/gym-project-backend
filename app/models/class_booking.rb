class ClassBooking < ApplicationRecord
  # Relationships
  has_many :bookings, dependent: :destroy
  has_many :users, through: :bookings

  # Validation
  validates :capacity, presence: true, numericality: { greater_than_or_equal_to: 1 }

  # --- Capacity Logic ---

  # Method to calculate spots remaining (read access)
  def spots_remaining
    # Use size for efficiency as bookings are loaded in the controller
    capacity - bookings.size 
  end

  # Helper method to check if the class is full (used in Booking validation)
  def full?
    bookings.size >= capacity
  end
  
  # Method to expose the current count of booked spots (read access)
  def booked_count
    bookings.size
  end
end