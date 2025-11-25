class Plan < ApplicationRecord

   attribute :features, :json, default: []


    has_many :memberships
    

end
