require 'rails_helper'

RSpec.describe Api::V1::RecipesController, type: :controller do
  describe "GET #index" do
    let!(:ingredient1) { create(:ingredient) }
    let!(:ingredient2) { create(:ingredient) }
    let!(:ingredient3) { create(:ingredient) }
    let!(:recipe1) { create(:recipe, ingredients: [ ingredient1, ingredient2 ]) }
    let!(:recipe2) { create(:recipe, ingredients: [ ingredient1, ingredient2, ingredient3 ]) }
    let!(:recipe3) { create(:recipe, ingredients: [ ingredient3 ]) }

    it "returns recipes that can be made with given ingredients" do
      get :index, params: { ingredient_ids: "#{ingredient1.id},#{ingredient2.id}" }
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response.length).to eq(1)
      expect(json_response.first["id"]).to eq(recipe1.id)
    end

    it "includes author, category, ingredients, and ingredient_data in the response" do
      get :index, params: { ingredient_ids: recipe1.ingredients.pluck(:id).join(',') }
      json_response = JSON.parse(response.body)

      expect(json_response.first).to include("author", "category", "ingredients", "ingredient_data")
    end

    it "returns an empty array when no recipes match the ingredients" do
      get :index, params: { ingredient_ids: "999999" }
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response).to eq([])
    end
  end

  describe "GET #show" do
    let!(:recipe) { create(:recipe) }

    it "returns the requested recipe" do
      get :show, params: { id: recipe.id }
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response["id"]).to eq(recipe.id)
    end

    it "includes author, category, ingredients, and ingredient_data in the response" do
      get :show, params: { id: recipe.id }
      json_response = JSON.parse(response.body)

      expect(json_response).to include("author", "category", "ingredients", "ingredient_data")
    end

    it "returns 404 for non-existent recipe" do
      expect {
        get :show, params: { id: 999999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
