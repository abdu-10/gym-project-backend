class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount_cents
      t.string :currency
      t.string :payment_method
      t.string :transaction_id
      t.string :status
      t.string :description

      t.timestamps
    end
  end
end
