class CreatePets < ActiveRecord::Migration
  def change
    create_table :pets do |t|
      t.string :name
      t.string :type_id, foreign_key: true
      t.string :sex
      t.string :color
      t.string :size
      t.integer :shelter_id, foreign_key: true

      t.timestamps null: false
    end
  end
end
