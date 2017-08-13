FactoryGirl.define do
  factory :dog, class: Type do
    name "dog"
    exotic false
  end

  factory :ocelot, class: Type do
    name "ocelot"
    exotic true
  end
end
