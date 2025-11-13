class TestimonialSerializer < ActiveModel::Serializer
  attributes :id, :quote, :author, :role, :image, :rating
end
