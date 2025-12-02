class ClassesController < ApplicationController

  # GET /classes
  def index
    # Fetch all classes and eager load their bookings for efficient counting
    @classes = ClassBooking.includes(:bookings).all

    # Render JSON including booking_id if current user booked it
    render json: @classes.map { |cls| class_with_capacity(cls) }
  end

  # GET /classes/:id
  def show
    @class = ClassBooking.find(params[:id])
    render json: class_with_capacity(@class)
  end

  def create
    @class = ClassBooking.new(class_booking_params)
    if @class.save
      render json: class_with_capacity(@class), status: :created
    else
      render json: { errors: @class.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def class_booking_params
    params.require(:class_booking).permit(:name, :category, :image_url, :duration, :instructor, :time, :capacity)
  end

  # Helper to format the ClassBooking object with computed attributes
  def class_with_capacity(cls)
    # Find booking for current user (if logged in)
    user_booking = cls.bookings.find_by(user_id: current_user&.id)

    cls.as_json(
      only: [:id, :name, :category, :image_url, :duration, :instructor, :time, :capacity]
    ).merge(
      spots_remaining: cls.spots_remaining,
      booked_count: cls.booked_count,
      booking_id: user_booking&.id # <-- this is key for cancellation
    )
  end
end
