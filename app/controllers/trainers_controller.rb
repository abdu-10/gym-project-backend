class TrainersController < ApplicationController
  def index
    @trainers = Trainer.all
    render json: @trainers
  end

  def show
    @trainer = Trainer.find(params[:id])
    render json: @trainer
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
end
