class AddUniqueConstraintToIngredientsName < ActiveRecord::Migration[7.2]
  def change
    add_index :ingredients, :name, unique: true
  end
end
