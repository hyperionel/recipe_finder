class AllowAuthorIdOnRecipeToBeOptional < ActiveRecord::Migration[7.2]
  def change
    change_column_null :recipes, :author_id, true
  end
end
