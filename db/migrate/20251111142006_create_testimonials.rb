class CreateTestimonials < ActiveRecord::Migration[8.1]
  def change
    create_table :testimonials do |t|
      t.string :quote
      t.string :author
      t.string :role
      t.string :image
      t.integer :rating

      t.timestamps
    end
  end
end
