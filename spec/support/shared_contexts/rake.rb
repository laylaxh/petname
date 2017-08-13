# Code from: https://robots.thoughtbot.com/test-rake-tasks-like-a-boss

# spec/support/shared_contexts/rake.rb
require "rake"

shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { self.class.top_level_description } # Use the text passed to describe to calculate the task that will be run
  let(:task_path) { "lib/tasks/#{task_name.split(":").first}" } # The file itself, relative to 'Rails.root'
  subject         { rake[task_name] }

  # The rake_require method takes three arguments: the path to the task, an array of directories to look for that path, and a 
  # list of all the files previously loaded. rake_require takes loaded paths into account, so we exclude the path to the task 
  # we’re testing so we have the task available.
  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == Rails.root.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment) 
  end
end
