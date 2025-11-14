class Plan < ApplicationRecord

    serialize :features, Array


    has_many :memberships
    
end
