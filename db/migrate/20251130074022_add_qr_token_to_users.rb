class AddQrTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :qr_token, :string
    add_index :users, :qr_token
  end
end
