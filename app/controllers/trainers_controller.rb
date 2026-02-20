class TrainersController < ApplicationController
  def index
    trainers = Trainer.all
    render json: trainers.map { |trainer| trainer_payload(trainer) }
  end

  def show
    trainer = Trainer.find(params[:id])
    render json: trainer_payload(trainer)
  end

  def available_slots
    trainer_id = params[:trainer_id]
    date = params[:date]

    if trainer_id.blank? || date.blank?
      return render json: { error: "trainer_id and date are required" }, status: :bad_request
    end

    begin
      available_times = TrainerBooking.available_slots_for_trainer(trainer_id, date)
      render json: { available_slots: available_times, date: date, trainer_id: trainer_id }
    rescue StandardError => e
      render json: { error: e.message }, status: :bad_request
    end
  end

  private

  def trainer_payload(trainer)
    {
      trainer_id: trainer.id,
      trainer_user_id: trainer.user_id,
      name: trainer.name,
      role: trainer.role,
      email: trainer.email,
      phone: trainer.phone,
      image: trainer.image,
      bio: trainer.bio,
      instagram: trainer.instagram,
      facebook: trainer.facebook,
      twitter: trainer.twitter,
      created_at: trainer.created_at,
      updated_at: trainer.updated_at
    }
  end
end
