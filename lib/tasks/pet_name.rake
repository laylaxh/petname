namespace :pet_name do
  task :fix_outdated_pet_names => :environment do |t, args|
    # filtered_shelters = Shelter.eager_load(pets: :type).where("type.exotic == false")
    shelters_with_exotic_animals = Shelter.joins(pets: :type).where(types: {exotic: true})
    shelters_without_exotic_animals = Shelter.where.not(id:shelters_with_exotic_animals)

    batch_count = 1

    shelters_without_exotic_animals.find_in_batches do |batch|
      pets_to_update = []
      batch.each do |shelter|
        pets_grouped_by_species = sort_pets_by_species_type(shelter)

          # {"fallout-crate"=>[#<Subscription id: 2, user_id: 1, plan_id: 3252>], "sanrio-crate"=>[#<Subscription id: 6, user_id: 1, plan_id: 1297>,#<Subscription id: 6, user_id: 1, plan_id: 1297>],...}
          # {"dog"=>[#<Pet id: 1, name: "dog 3", type_id: "2", sex: nil, color: nil, size: nil, shelter_id: 2, created_at: "2017-08-09 15:48:58", updated_at: "2017-08-11 15:37:41", breed: "Husky">, #<Pet id: 3, name: "roxy", type_id: "2", sex: nil, color: nil, size: nil, shelter_id: 2, created_at: "2017-08-10 22:32:47", updated_at: "2017-08-11 15:39:49", breed: "Yorkie">, #<Pet id: 5, name: "Kole 4", type_id: "2", sex: nil, color: nil, size: nil, shelter_id: 2, created_at: "2017-08-11 15:40:41", updated_at: "2017-08-11 15:40:41", breed: "Lab">, #<Pet id: 6, name: "Yorkie 3", type_id: "2", sex: nil, color: nil, size: nil, shelter_id: 2, created_at: "2017-08-11 15:41:28", updated_at: "2017-08-11 15:41:28", breed: "Yorkie">]}
        next if pets_grouped_by_species.count == 0

        # for each species, rename the pets in that species so they have a more specific name
        # the exception is if the pets name has already been customized/personalized
        # ex: Dog 10 and Dog 11 could be renamed to Golden Retriever 9 and Yorkie 13 depending on the
        #     other dogs of the same species at the shelter and the date/time they were admitted 
        #     Charlie will not be renamed because his name has been personalized
        pets_grouped_by_species.each do |species_name,pets|
          uncustomized_pets = pets.select do |pet|
            pet.name =~ /^#{pet.type.name} \d+$|^#{pet.breed} \d+$/  # We still want to rename Yorkie 4 
          end                                                     # because it might get renumbered
          uncustomized_pets_ordered = uncustomized_pets.sort_by(&:created_at) # Order all uncustomized pets

          begin
            rename_pets(uncustomized_pets_ordered, pets_to_update)
          rescue
            puts "Failure occurred in rename_pets"
          end
        end 
      end
      Pet.import pets_to_update, on_duplicate_key_update: [:name], validate:false
      puts "Renaming in DB complete for #{batch.count} Shelters(s) in Batch #{batch_count} of Update"
      batch_count += 1
    end
  end

  private

  def sort_pets_by_species_type(shelter)
    shelter.pets.group_by do |pet|
      pet.type.name
    end
  end

  def rename_pets(uncustomized_pets_ordered, pets_to_update)
    counter = 1
    uncustomized_pets_ordered.each do |pet|
      pet.name = "#{pet.breed} #{counter}"
      pets_to_update << pet
      counter += 1
    end
  end
end
