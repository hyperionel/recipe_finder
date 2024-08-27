module Api
  module V1
    class IngredientsController < ApplicationController
      def index
        if params[:query]
          @ingredients = Ingredient.where("name ILIKE ?", "%#{params[:query]}%").limit(10)
        else
          @ingredients = Ingredient.order("RANDOM()").limit(50)
        end
        render json: @ingredients
      end
    end
  end
end
