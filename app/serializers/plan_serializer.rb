class PlanSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :period, :features, :popular
end
