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
      import_data = []
      recipe_ingredients = []

      batch.each do |recipe_data|
        recipe = Recipe.new(
          title: recipe_data["title"],
          cook_time: recipe_data["cook_time"],
          prep_time: recipe_data["prep_time"],
          ratings: recipe_data["ratings"],
          cuisine: recipe_data["cuisine"],
          image: recipe_data["image"],
          ingredient_data: recipe_data["ingredients"]
        )

        import_data << {
          recipe: recipe,
          ingredients: recipe_data["ingredients"].map { |ingredient| parser.parse_ingredient(ingredient) },
          category: recipe_data["category"],
          author: recipe_data["author"]
        }
      end

      # Bulk upsert categories, authors, and ingredients
      category_mapping = upsert_and_get_mapping(Category, import_data.map { |data| data[:category] }.uniq)
      ingredient_mapping = upsert_and_get_mapping(Ingredient, import_data.map { |data| data[:ingredients] }.flatten.uniq)

      # map Author separately since the import gem doesn't like its special unique constraint
      author_results = Author.import import_data.map { |data| Author.new(name: data[:author]) }, on_duplicate_key_ignore: true
      author_mapping = Author.find(author_results.ids).pluck(:name, :id).to_h

      # Update recipes with category and author id, then bulk insert
      import_data.each do |data|
        data[:recipe].category_id = category_mapping[data[:category]]
        data[:recipe].author_id = author_mapping[data[:author]]
      end
      imported_recipes = Recipe.import import_data.map { |r| r[:recipe] }
      recipe_mapping = Recipe.find(imported_recipes.ids).index_by(&:title)

      # Build and Import RecipeIngredients
      import_data.each do |data|
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
                   on_duplicate_key_ignore: true
      model.where(name: names).pluck(:name, :id).to_h
    end
  end
end
