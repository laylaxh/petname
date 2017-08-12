class Pet < ActiveRecord::Base
  belongs_to :shelter
  belongs_to :type
end

class Shelter < ActiveRecord::Base
  has_many :pets
end

class Type < ActiveRecord::Base
  has_many :pets
end

# # find shelters that don't have any exotic pets
# Shelter.joins(:pet => :type).where(:types => {exotic => false})

# Shelter.joins(pets: [:type]).where("pets.type.exotic is false")

# # find shelters that don't have pets that are type exotic

# # PET Shelter
# # 1    1
# # 2    1
# # 3    1
# # 4    2




class Track < ActiveRecord::Base
    belongs_to :album
end

class Album < ActiveRecord::Base
    has_many :tracks
end

class Band < ActiveRecord::Base
    has_many :albums
    has_many :tracks
end
