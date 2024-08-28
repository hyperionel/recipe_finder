class AddIngredientDataToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_column :recipes, :ingredient_data, :jsonb
  end
end
