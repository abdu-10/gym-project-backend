class AddUserIdToTrainers < ActiveRecord::Migration[8.1]
  def change
    add_reference :trainers, :user, null: true, foreign_key: true
  end
end
