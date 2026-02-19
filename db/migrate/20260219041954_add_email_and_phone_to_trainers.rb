class AddEmailAndPhoneToTrainers < ActiveRecord::Migration[8.1]
  def change
    add_column :trainers, :email, :string
    add_column :trainers, :phone, :string
  end
end
