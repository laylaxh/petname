=begin
  Title: RSpec Test for Ruby Script Coding Sample
  Author: Layla Habahbeh
  Description: The 'pet.name' rake task was written using Test Driven Development (TDD)
               and covers each possible path
  Instructions to run this test: 
    1. Copy the file path of this spec file 
    2. Run spec in the console: 'rspec <filepath>'
=end

require 'rails_helper'
require "./spec/support/shared_contexts/rake.rb"
require 'factory_girl' # factory_girl is a library for setting up Ruby objects as test data

describe "pet_name:fix_outdated_pet_names" do
  # The rake code has been extracted into a separate class - it is accessed using 'include_context'
  include_context "rake" 

  # Factories are defined in './spec/factories' and can be called using create(:<factory_name>)
  # Each factory has a name as a set of attributes
  before do
    @shelter_vanilla = create(:shelter_without_exotic) # Returns a saved Shelter instance
    @shelter_exotic = create(:shelter_with_exotic)     # Returns a saved Shelter instance
    @type_vanilla = create(:dog)                       # Returns a saved Type instance
    @type_exotic = create(:ocelot)                     # Returns a saved Type instance

    # Build Pet instances and override some of their attributes
    @charlie = create(:charlie, shelter_id: @shelter_exotic.id, type_id: @type_vanilla.id)
    @dog = create(:generic_dog, shelter_id: @shelter_vanilla.id, type_id: @type_vanilla.id, created_at: 'DateTime.new(2017, 2)')
    @dog_newer = create(:generic_dog, shelter_id: @shelter_vanilla.id, type_id: @type_vanilla.id, created_at: 'DateTime.new(2017, 4)')
    @dog_yorkie = create(:generic_dog, breed: "yorkie", shelter_id: @shelter_vanilla.id, type_id: @type_vanilla.id, created_at: 'DateTime.new(2017, 3)')
    @rocket = create(:generic_dog, name: "Rocket", shelter_id: @shelter_vanilla.id, type_id: @type_vanilla.id, created_at: 'DateTime.new(2017, 3)')
    @babou = create(:babou, shelter_id: @shelter_exotic.id, type_id: @type_exotic.id)
  end  

  let(:dog) { Pet.find(@dog.id) }
  let(:charlie) { Pet.find(@charlie.id) }

  context "when a shelter has exotic animals" do
    let(:babou) { Pet.find(@babou.id) }

    it "does not modify the name of any animals, regardless of whether it's exotic or not" do
      expect(dog.name).to eq('dog 1')
      expect(charlie.name).to eq('Charlie Suh')
      expect(babou.name).to eq('Babou')
    end
  end

  context "when a shelter does not have exotic animals" do
    let(:dog_newer) { Pet.find(@dog_newer.id) }
    let(:dog_yorkie) { Pet.find(@dog_yorkie.id) }
    let(:rocket) { Pet.find(@rocket.id)}

    it "updates the incorrectly labeled, uncustomized pet names" do
      subject.invoke

      expect(dog.name).to eq('husky 1')
    end

    it "does not update customized pet named that do not follow the standard naming convention of <Species> #, ex: Dog 1" do
      subject.invoke

      expect(dog.name).to eq('husky 1')
      expect(charlie.name).to eq('Charlie Suh')
    end

    it "choronologically numbers animals of the same breed based on their created_at/date-of-admission to the shelter" do
      subject.invoke

      expect(dog.name).to eq('husky 1')
      expect(dog_newer.name).to eq('husky 2')
    end

    it "only chronologically numbers animals whose names have not been customized" do
      subject.invoke 

      expect(dog.name).to eq('husky 1')
      expect(rocket.name).to eq('Rocket')
      expect(dog_newer.name).to eq('husky 2')
    end
  end
end
