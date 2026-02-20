class Trainer < ApplicationRecord
  belongs_to :user, optional: true
end
