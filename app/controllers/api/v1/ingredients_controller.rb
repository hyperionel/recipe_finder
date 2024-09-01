module Api
  module V1
    class IngredientsController < ApplicationController
      def autocomplete
        @ingredients = params[:query] ? ordered_autocomplete : []
        render json: @ingredients
      end

      def surprise
        @ingredients = surprise_ingredients
        render json: @ingredients
      end

      private

        def surprise_ingredients
          # get the ingredients of 5 recipes so we will display at least 5 recipes to the user
          random_recipe_ids = Recipe.order("RANDOM()").limit(5).pluck(:id)
          Ingredient.joins(:recipes)
            .where(recipes: { id: random_recipe_ids })
            .select("ingredients.*, RANDOM() as random_order")
            .distinct.limit(50)
        end

        def ordered_autocomplete
          query = params[:query].downcase
          Ingredient.where("LOWER(name) LIKE ?", "%#{query}%")
            .order(Arel.sql("similarity(LOWER(name), LOWER(#{ActiveRecord::Base.connection.quote(query)})) DESC, LENGTH(name) ASC"))
            .limit(10)
        end
    end
  end
end
