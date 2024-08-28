module Recipes
  class Importer
    def self.import(json_data, batch_size: 500)
      parser = Recipes::Parser.new
      recipes = JSON.parse(json_data)

      Recipe.transaction do
        recipes.each_slice(batch_size) do |batch|
          import_batch(batch, parser)
        end
      end
    end

    private

    def self.import_batch(batch, parser)
      recipes = []
      categories = Set.new
      authors = Set.new
      ingredients = Set.new
      recipe_ingredients = []

      batch.each do |recipe_data|
        parsed_ingredient_list = []
        categories.add(recipe_data["category"])
        authors.add(recipe_data["author"])

        recipe = Recipe.new(
          title: recipe_data["title"],
          cook_time: recipe_data["cook_time"],
          prep_time: recipe_data["prep_time"],
          ratings: recipe_data["ratings"],
          cuisine: recipe_data["cuisine"],
          image: recipe_data["image"],
          ingredient_data: recipe_data["ingredients"]
        )

        recipe_data["ingredients"].each do |ingredient_string|
          parsed_ingredient = parser.parse_ingredient(ingredient_string)
          ingredients.add(parsed_ingredient)
          parsed_ingredient_list << parsed_ingredient
        end

        recipes << { recipe: recipe, ingredients: parsed_ingredient_list }
      end

      # Bulk upsert categories, authors, and ingredients
      category_mapping = upsert_and_get_mapping(Category, categories.to_a)
      ingredient_mapping = upsert_and_get_mapping(Ingredient, ingredients.to_a)

      # map Author separately since the import gem doesn't like its special unique constraint
      Author.import authors.to_a.map { |name| { name: name } }, on_duplicate_key_ignore: true
      author_mapping = Author.where(name: authors.to_a).pluck(:name, :id).to_h

      # Update recipes with category and author id, then bulk insert
      recipes.each do |data|
        data[:recipe].category_id = category_mapping[data[:recipe].category]
        data[:recipe].author_id = author_mapping[data[:recipe].author]
      end
      imported_recipes = Recipe.import recipes.map { |r| r[:recipe] }, validate: false
      recipe_mapping = Recipe.find(imported_recipes.ids).index_by(&:title)

      # Build and Import RecipeIngredients
      recipes.each do |data|
        recipe = recipe_mapping[data[:recipe].title]
        data[:ingredients].each do |ingredient|
          recipe_ingredients << RecipeIngredient.new(
            recipe_id: recipe.id,
            ingredient_id: ingredient_mapping[ingredient]
          )
        end
      end

      RecipeIngredient.import recipe_ingredients, on_duplicate_key_ignore: true
    end

    def self.upsert_and_get_mapping(model, names)
      model.import names.map { |name| { name: name } },
                   on_duplicate_key_update: { conflict_target: [ :name ], columns: [ :name ] },
                   validate: false
      model.where(name: names).pluck(:name, :id).to_h
    end
  end
end
