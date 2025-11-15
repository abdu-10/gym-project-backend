class AddPriceInCentsToPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :plans, :price_in_cents, :integer
  end
end
