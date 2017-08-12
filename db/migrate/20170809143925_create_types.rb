class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      t.string :name
      t.boolean :exotic

      t.timestamps null: false
    end
  end
end
