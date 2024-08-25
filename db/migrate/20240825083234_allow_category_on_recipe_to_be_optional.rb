class AllowCategoryOnRecipeToBeOptional < ActiveRecord::Migration[7.2]
  def change
    change_column_null :recipes, :category_id, true
  end
end
