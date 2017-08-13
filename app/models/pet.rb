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
