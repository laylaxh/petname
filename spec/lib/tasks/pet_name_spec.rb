require 'rails_helper'
require "./spec/support/shared_contexts/rake.rb"
# require 'support/factory_girl'

describe "pet_name:fix_outdated_pet_names" do
  include_context "rake"

  let(:generic_pet) { Pet.find(@dog.id) }
  let(:charles) { Pet.find(@charles.id) }

  before do
    @shelter = Shelter.create(name: "East LA Shelter")
    @type = Type.create(name: "dog")
    @dog = Pet.create(name: "dog 4", shelter_id: @shelter.id, type_id: @type.id, breed: "yorkie")
    @charles = Pet.create(name: "charles", shelter_id: @shelter.id, type_id: @type.id)
    # @shelter = create(:shelter)
    # @type = create(:dog)
    # @pet1 = create(:charlie, shelter_id: @shelter.id, type_id: @type.id, created_at: 'DateTime.new(2017, 2)')
  end  

  it "updates the incorrectly labeled, uncustomized pet names" do
    subject.invoke

    puts "GENERIC PET: #{generic_pet.name}"
    puts "CHARLES: #{charles.name}"

    expect(generic_pet.name).to eq('yorkie 1')
    expect(charles.name).to eq('charles')
  end
end
