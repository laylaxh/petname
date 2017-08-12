class ChangeTypeIdFormatInPets < ActiveRecord::Migration
  def change
    execute %q{
      alter table pets
      alter column type_id
      type int using cast(type_id as int)
    }
  end
end
