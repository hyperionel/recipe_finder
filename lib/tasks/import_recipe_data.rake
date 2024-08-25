namespace :recipes do
  desc "Parse recipes from JSON file"
  task import_data: :environment do
    Recipes::Importer.import(File.read("spec/fixtures/recipes-en.json"))
    puts "Recipes have been parsed and saved."
  end
end
