# app/controllers/testimonials_controller.rb

class TestimonialsController < ApplicationController

  # Use a before_action to find the testimonial for show, update, and destroy
  before_action :set_testimonial, only: [:show, :update, :destroy]

  # GET /testimonials
  def index
    @testimonials = Testimonial.all
    render json: @testimonials
  end

  # GET /testimonials/:id
  def show
    render json: @testimonial
  end

  # POST /testimonials
  def create
    # Use create! (with a '!') to raise an error if validation fails
    @testimonial = Testimonial.create!(testimonial_params)
    render json: @testimonial, status: :created
  rescue ActiveRecord::RecordInvalid => e
    # If validation fails, render the errors
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  # PUT /testimonials/:id
  # or
  # PATCH /testimonials/:id
  def update
    # Use update! (with a '!') to raise an error if validation fails
    @testimonial.update!(testimonial_params)
    render json: @testimonial
  rescue ActiveRecord::RecordInvalid => e
    # If validation fails, render the errors
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  # DELETE /testimonials/:id
  def destroy
    @testimonial.destroy
    # Send a 204 No Content response to show it worked
    head :no_content
  end

  private

  # Find the specific testimonial based on the :id in the URL
  def set_testimonial
    @testimonial = Testimonial.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Testimonial not found" }, status: :not_found
  end

  # Strong params: Whitelist the attributes you'll allow
  def testimonial_params
    params.require(:testimonial).permit(:quote, :author, :role, :image, :rating)
  end
end