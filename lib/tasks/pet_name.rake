=begin
  Title: Ruby Script Coding Sample
  Author: Layla Habahbeh
  Instructions to test this script: 
    1. Copy the file path of the related spec file: 'pet_name_spec.rb'
    2. Run spec in the console: 'rspec <filepath>'
  Description: A rake task that backfills animal shelter databases and efficiently renames animals based on the 
  following criteria:
    1. Shelters that house any exotic animals are being closed down. Don't bother renaming any animals in 
       those shelters, even if they are not exotic.
    2. Current animal names are species based - they must be renamed to be more specific based on the breed.
         Before script: Dog 1
          After script: Husky 1
    3. Each animal within a breed should be renumbered based on the date/time they were admitted to the shelter.
    4. Animals who enter the shelter with a custimized name, like 'Fluffy,' will retain it's customized name.
        Before script: Fluffy
         After script: Fluffy
  Helpful tips: 
    The DB structure is held in 'db/schema.rb' - you can see the attributes for the Pet, Type, and Shelter models here
    DB relationships can be seen in the 'app/models' directory
=end

namespace :pet_name do
  task :fix_outdated_pet_names => :environment do
    # Query the DB of shelters to filter out shelters that contain any number of exotic animals
    shelters_with_exotic_animals = Shelter.joins(pets: :type).where(types: {exotic: true})
    shelters_without_exotic_animals = Shelter.where.not(id:shelters_with_exotic_animals)

    batch_count = 1

    # Iterate through the filtered shelters in batches of 50 - each batch yields an array  
    shelters_without_exotic_animals.find_in_batches(:batch_size => 50) do |batch|
      pets_to_update = [] # Initialize an empty array to store renamed pets in order to do a mass update
      
      # Iterate through each shelter in the current batch of 50
      batch.each do |shelter|

        # Create a hash of hashes where each key is a breed and each value is an array of animals of that breed:
        #   {  "husky"=>[#<Pet id: 677, name: "dog 1", type_id: 272, shelter_id: 272, ..., breed: "husky">, 
                        #<Pet id: 680, name: "Rocket", type_id: 272, shelter_id: 272, ..., breed: "husky">], 
        #   {"siamese"=>[#<Pet id: 679, name: "cat 7", type_id: 122, shelter_id: 272, ..., breed: "siamese">]}
        pets_grouped_by_breed = sort_pets_by_breed(shelter) 
        
        next if pets_grouped_by_breed.count == 0 # Abort this loop and move onto the next one if there are no results to assess 

        # Iterate through each breed, identify which pets to rename, and rename them
        pets_grouped_by_breed.each do |breed,pets|

          # Select pets with either the standard naming convention of either '<species type> #', ex: 'Cat 8'
          # If a pet's name already has the new naming convention of '<breed> #', we still want to add it to the uncustomized_pets
          # array because it will likely need renumbering based on the comparison of it's admittance date to others of it's breed
          uncustomized_pets = pets.select do |pet|
            pet.name =~ /^#{pet.type.name} \d+$|^#{pet.breed} \d+$/ 
          end                                                     
          uncustomized_pets_ordered = uncustomized_pets.sort_by(&:created_at) # Order the filtered array by admittance date/time

          # Transaction to rename the finalized list of pets
          begin
            rename_pets(uncustomized_pets_ordered, pets_to_update)
          rescue
            puts "Failure occurred in renaming pets."
          end
        end 
      end
      # .import is a function of the activerecord-import library for bulk inserting data using ActiveRecord - it generates
      # the minimal number of SQL insert statments required, avoiding the N+1 insert issue
      # on_duplicate_key_update[:name] updates the name field if a primary or unique key constraint is violated 
      # in the Pet ActiveRecord model
      Pet.import pets_to_update, on_duplicate_key_update: [:name], validate:false
      puts "Renaming in DB complete for #{batch.count} Shelters(s) in Batch #{batch_count} of Update"
      batch_count += 1
    end
  end

  private

  # Group the collection of shelter pets by breed and return a hash where the keys are each breed and the values are arrays 
  # of pets in the collection that correspond to the key
  def sort_pets_by_breed(shelter)
    shelter.pets.group_by do |pet|
      pet.breed
    end
  end

  # Each pet in the finalized list is renamed in order of admittance and injected into the pets_to_update array
  # that will accumulate updated pet names and rename them in the DB as a batch instead of individually
  def rename_pets(uncustomized_pets_ordered, pets_to_update)
    counter = 1  # Because the pets are ordered by admittance date already, a counter can be used to properly number them
    uncustomized_pets_ordered.each do |pet|
      pet.name = "#{pet.breed} #{counter}"
      pets_to_update << pet
      counter += 1
    end
  end
end
