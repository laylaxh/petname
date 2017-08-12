class AddBreedToPets < ActiveRecord::Migration
  def change
    add_column :pets, :breed, :string
  end
end
