module Api
  module V1
    class RecipesController < ApplicationController
      def index
        ingredient_ids = params["ingredient_ids"].split(",")
        @recipes = Recipe.joins(:recipe_ingredients)
        .includes(:author, :category, :ingredients)
        .group("recipes.id")
        .having("ARRAY_AGG(recipe_ingredients.ingredient_id) <@ ARRAY[?]::bigint[]", ingredient_ids)
        render json: @recipes, include: [ :ingredients, :category, :author ]
      end
    end
  end
end
