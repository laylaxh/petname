require 'rails_helper'
require 'rake'
# Rails.application.load_tasks
# Rake::Task[pet_name:fix_outdated_pet_names].invoke
# require_relative '../../../lib/tasks/pet_name.rake'
# require 'support/factory_girl'

describe 'pet_name' do
  let(:rake)      { Rake::Application.new }
  let(:task_filename) { self.class.top_level_description }
  let(:task_path) { "lib/tasks/#{task_filename.split(":").first}" }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == Rails.root.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)

    # ::Petname::Application.load_tasks
    @shelter = Shelter.create(name: "East LA Shelter")
    @type = Type.create(name: "dog")
    @dog = Pet.create(name: "dog 4", shelter_id: @shelter.id, type_id: @type.id, breed: "yorkie")
    @charles = Pet.create(name: "charles", shelter_id: @shelter.id, type_id: @type.id)
    # @shelter = create(:shelter)
    # @type = create(:dog)
    # @pet1 = create(:charlie, shelter_id: @shelter.id, type_id: @type.id, created_at: 'DateTime.new(2017, 2)')
  end

  describe 'fix outdated pet names' do
    subject { rake['pet_name:fix_outdated_pet_names'] }

    context "example context" do

      let(:generic_pet) { Pet.find(@dog.id) }
      let(:charles) { Pet.find(@charles.id) }

      it "updates the incorrectly labeled, uncustomized pet names" do
        subject.invoke

        puts "GENERIC PET: #{generic_pet.name}"
        puts "CHARLES: #{charles.name}"

        expect(generic_pet.name).to eq('yorkie 1')
        expect(charles.name).to eq('charles')
        
      end
    end
  end
end
