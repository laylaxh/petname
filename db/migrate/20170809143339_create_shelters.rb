class CreateShelters < ActiveRecord::Migration
  def change
    create_table :shelters do |t|
      t.string :name
      t.string :street_address
      t.string :string
      t.string :city
      t.string :state
      t.string :email
      t.integer :quantity, default:0

      t.timestamps null: false
    end
  end
end
