module Recipes
  class Importer
    def self.import(json_data, batch_size: 500)
      parser = Recipes::Parser.new
      recipes = JSON.parse(json_data)
      total_batches = (recipes.size.to_f / batch_size).ceil

      Recipe.transaction do
        recipes.each_slice(batch_size).with_index(1) do |batch, index|
          Rails.logger.info "Processing batch #{index} of #{total_batches}"
          import_batch(batch, parser)
          Rails.logger.info "Completed batch #{index}"
        end
      end

      Rails.logger.info "Import completed successfully"
    end

    private

    def self.import_batch(batch, parser)
      related_data = Struct.new(:recipe, :category, :author)
      related_data_arr = []
      ingredients = []
      recipe_ingredients = []

      batch.each do |recipe_data|
        parsed_ingredient_list = []
        category_name = recipe_data["category"]
        author_name = recipe_data["author"]

        recipe = Recipe.new(
          title: recipe_data["title"],
          cook_time: recipe_data["cook_time"],
          prep_time: recipe_data["prep_time"],
          ratings: recipe_data["ratings"],
          cuisine: recipe_data["cuisine"],
          image: recipe_data["image"]
        )
        recipe_data["ingredients"].each do |ingredient_string|
          parsed_ingredient = parser.parse_ingredient(ingredient_string)
          ingredients << Ingredient.new(name: parsed_ingredient)
          parsed_ingredient_list << parsed_ingredient
        end

        related_data_arr << related_data.new({ recipe => parsed_ingredient_list }, category_name, author_name)
      end

      # Bulk insert or update categories and get mapping
      new_categories = related_data_arr.map { |data| Category.new(name: data.category) }
      imported_categories = Category.import new_categories, on_duplicate_key_ignore: true
      category_mapping = Category.find(imported_categories.ids).pluck(:id, :name)

      # Bulk insert or update authors and get mapping
      new_authors = related_data_arr.map { |data| Author.new(name: data.author) }
      imported_authors = Author.import new_authors, on_duplicate_key_ignore: true
      author_mapping = Author.find(imported_authors.ids).pluck(:id, :name)

      # Update recipes with category and author id
      related_data_arr.each do |data|
        data.recipe.keys.first.category_id = category_mapping.select { |cat| cat[1] == data.category }&.first&.first
        data.recipe.keys.first.author_id = author_mapping.select { |cat| cat[1] == data.author }&.first&.first
      end

      # Bulk insert recipes
      recipes = related_data_arr.map { |data| data.recipe.keys.first }
      imported_recipes = Recipe.import recipes, validate: false
      recipe_mapping = Recipe.find(imported_recipes.ids).pluck(:id, :title)

      # Bulk insert ingredients
      imported_ingredients = Ingredient.import ingredients, on_duplicate_key_ignore: true
      ingredient_mapping = Ingredient.find(imported_ingredients.ids).pluck(:id, :name)

      # Build and Import RecipeIngredients
      related_data_arr.each do |data|
        recipe_id = recipe_mapping.select { |recipe| recipe[1] == data.recipe.keys.first.title }&.first&.first
        data.recipe.values.first.each do |ing_title|
          ingredient_id = ingredient_mapping.select { |ingredient| ingredient[1] == ing_title }&.first&.first
          recipe_ingredients << RecipeIngredient.new(recipe_id: recipe_id, ingredient_id: ingredient_id)
        end
      end
      RecipeIngredient.import recipe_ingredients, on_duplicate_key_ignore: true
    end
  end
end
