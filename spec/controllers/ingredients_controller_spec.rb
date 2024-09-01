require 'rails_helper'

RSpec.describe Api::V1::IngredientsController, type: :controller do
  describe "GET #autocomplete" do
    before do
      create(:ingredient, name: "Apple")
      create(:ingredient, name: "Apricot")
      create(:ingredient, name: "Banana")
    end

    it "returns matching ingredients ordered by similarity" do
      get :autocomplete, params: { query: "ap" }
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response.length).to eq(2)
      expect(json_response.first["name"]).to eq("Apple")
      expect(json_response.second["name"]).to eq("Apricot")
    end

    it "is case insensitive" do
      get :autocomplete, params: { query: "AP" }
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response.length).to eq(2)
    end

    it "returns an empty array when no query is provided" do
      get :autocomplete
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response).to eq([])
    end
  end

  describe "GET #surprise" do
    before do
      create_list(:recipe, 10) do |recipe|
        create_list(:ingredient, 5, recipes: [ recipe ])
      end
    end

    it "returns a list of ingredients" do
      get :surprise
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response).to be_an(Array)
      expect(json_response).not_to be_empty
    end

    it "returns ingredients from at least 5 recipes" do
      get :surprise
      json_response = JSON.parse(response.body)

      ingredient_ids = json_response.map { |i| i["id"] }
      recipe_count = Recipe.joins(:ingredients).where(ingredients: { id: ingredient_ids }).distinct.count

      expect(recipe_count).to be >= 5
    end

    it "limits the number of ingredients to 50" do
      get :surprise
      json_response = JSON.parse(response.body)

      expect(json_response.length).to be <= 50
    end

    it "returns distinct ingredients" do
      get :surprise
      json_response = JSON.parse(response.body)

      ingredient_ids = json_response.map { |i| i["id"] }
      expect(ingredient_ids.uniq).to eq(ingredient_ids)
    end
  end
end
