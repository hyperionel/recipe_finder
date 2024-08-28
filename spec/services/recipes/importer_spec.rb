require 'rails_helper'

RSpec.describe Recipes::Importer do
  let(:json_data) do
    [
      {
        "title" => "Spaghetti Carbonara",
        "cook_time" => 15,
        "prep_time" => 10,
        "ratings" => 4.5,
        "cuisine" => "Italian",
        "category" => "Pasta",
        "author" => "Chef John",
        "image" => "http://example.com/carbonara.jpg",
        "ingredients" => [
          "200 grams spaghetti",
          "100 grams pancetta, diced",
          "2 large eggs",
          "50 grams pecorino cheese, grated",
          "50 grams parmesan, grated",
          "Freshly ground black pepper to taste"
        ]
      },
      {
        "title" => "Caesar Salad",
        "cook_time" => 0,
        "prep_time" => 20,
        "ratings" => 4.2,
        "cuisine" => "American",
        "category" => "Salad",
        "author" => "Julia Child",
        "image" => "http://example.com/caesar.jpg",
        "ingredients" => [
          "1 large cos lettuce, torn into pieces",
          "2 slices bread, cubed",
          "2 tablespoons olive oil",
          "2 garlic cloves, minced",
          "2 eggs, boiled and separated",
          "4 tablespoons lemon juice"
        ]
      }
    ].to_json
  end

  describe '.import' do
    it 'imports recipes from JSON data' do
      expect {
        described_class.import(json_data)
      }.to change(Recipe, :count).by(2)
         .and change(Category, :count).by(2)
         .and change(Author, :count).by(2)
         .and change(Ingredient, :count).by(11)
         .and change(RecipeIngredient, :count).by(12)
    end

    it 'sets the correct attributes for imported recipes' do
      described_class.import(json_data)

      spaghetti = Recipe.find_by(title: "Spaghetti Carbonara")
      expect(spaghetti).to have_attributes(
        cook_time: 15,
        prep_time: 10,
        ratings: 4.5,
        cuisine: "Italian",
        image: "http://example.com/carbonara.jpg"
      )
      expect(spaghetti.category.name).to eq("Pasta")
      expect(spaghetti.author.name).to eq("Chef John")
      expect(spaghetti.ingredients.pluck(:name)).to contain_exactly(
        "spaghetti", "pancetta", "eggs", "pecorino cheese", "parmesan", "freshly ground black pepper to taste"
      )
      expect(spaghetti.ingredient_data).to eq([
        "200 grams spaghetti",
        "100 grams pancetta, diced",
        "2 large eggs",
        "50 grams pecorino cheese, grated",
        "50 grams parmesan, grated",
        "Freshly ground black pepper to taste"
      ])
    end

    it 'handles duplicate categories, authors, and ingredients' do
      # First import
      described_class.import(json_data)

      # Second import with same data
      expect {
        described_class.import(json_data)
      }.to change(Recipe, :count).by(2)
         .and change(Category, :count).by(0)
         .and change(Author, :count).by(0)
         .and change(Ingredient, :count).by(0)
         .and change(RecipeIngredient, :count).by(12)
    end

    it 'processes recipes in batches' do
      allow(described_class).to receive(:import_batch).and_call_original
      described_class.import(json_data, batch_size: 1)
      expect(described_class).to have_received(:import_batch).twice
    end

    it 'correctly parses and normalizes ingredients' do
      described_class.import(json_data)

      caesar_salad = Recipe.find_by(title: "Caesar Salad")
      expect(caesar_salad.ingredients.pluck(:name)).to contain_exactly(
        "cos lettuce", "bread", "olive oil", "garlic cloves", "eggs", "lemon juice"
      )

      garlic = Ingredient.find_by(name: "garlic cloves")
      recipe_ingredient = RecipeIngredient.find_by(recipe: caesar_salad, ingredient: garlic)
      expect(recipe_ingredient).to be_present
    end
  end

  describe '.upsert_and_get_mapping' do
    it 'creates new records for new names' do
      names = [ 'Italian', 'French', 'Chinese' ]
      expect {
        described_class.send(:upsert_and_get_mapping, Category, names)
      }.to change(Category, :count).by(3)
    end

    it 'does not create duplicates for existing names' do
      Category.create(name: 'Italian')
      names = [ 'Italian', 'French' ]
      expect {
        described_class.send(:upsert_and_get_mapping, Category, names)
      }.to change(Category, :count).by(1)
    end

    it 'returns a hash mapping names to ids' do
      names = [ 'Italian', 'French' ]
      mapping = described_class.send(:upsert_and_get_mapping, Category, names)
      expect(mapping).to be_a(Hash)
      expect(mapping.keys).to contain_exactly('Italian', 'French')
      expect(mapping.values).to all(be_a(Integer))
    end
  end
end
