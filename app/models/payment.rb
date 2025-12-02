class Payment < ApplicationRecord
  belongs_to :user

  # Optional: Validations to ensure data integrity
  validates :amount_cents, presence: true
end
