module Api
  module V1
    class IngredientsController < ApplicationController
      def index
        if params[:query]
          ordered_autocomplete
        else
          random_ingredients
        end
        render json: @ingredients
      end

      private

        def random_ingredients
          # make sure there's at least some recipes when fetching random ingredients
          @ingredients = Ingredient.order("RANDOM()").limit(50)

          random_recipes = random_recipes = Recipe.order("RANDOM()").limit(4)

          recipe_ingredients = Ingredient
                                  .joins(:recipes).where(recipes: { id: random_recipes.pluck(:id) })
                                  .distinct

          additional_count = [ 30 - recipe_ingredients.count, 0 ].max

          additional_ingredients = Ingredient.where.not(id: recipe_ingredients.pluck(:id))
                                      .order("RANDOM()")
                                      .limit(additional_count)

          @ingredients = (recipe_ingredients + additional_ingredients).shuffle
        end

        def ordered_autocomplete
          query = params[:query].downcase
          @ingredients = Ingredient
            .where("LOWER(name) LIKE ?", "%#{query}%")
            .order(Arel.sql("similarity(LOWER(name), LOWER(#{ActiveRecord::Base.connection.quote(query)})) DESC, LENGTH(name) ASC"))
            .limit(10)
        end
    end
  end
end
