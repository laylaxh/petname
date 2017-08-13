FactoryGirl.define do
  factory :shelter_without_exotic, class: Shelter do
    name "Eastside Animal Shelter"
    city "Los Angeles"
    state "CA"
  end

  factory :shelter_with_exotic, class: Shelter do
    name "Westside Wildlife Shelter"
    city "Malibu"
    state "CA"
  end
end
