FactoryGirl.define do
  factory :dog, class: Type do
    name "dog"
    exotic false
  end

  factory :unicorn, class: Type do
    name "unicorn"
    exotic true
  end
end
