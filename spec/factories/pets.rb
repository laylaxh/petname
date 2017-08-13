FactoryGirl.define do
  factory :generic_dog, class: Pet do
    name "dog 1"
    sex "female"
    color "grey"
    size "large"
    breed "husky"
  end

  factory :babou, class: Pet do
    name "Babou"
    sex "male"
    color "black"
    size "medium"
    breed "ocelot"
  end

  factory :charlie, class: Pet do
    name "Charlie Suh"
    sex "male"
    color "grey"
    size "small"
    breed "yorkie"
  end
end
