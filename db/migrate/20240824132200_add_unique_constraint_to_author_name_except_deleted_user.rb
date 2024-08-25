class AddUniqueConstraintToAuthorNameExceptDeletedUser < ActiveRecord::Migration[7.2]
  def change
    add_index :authors, :name, unique: true, where: "name != 'deleteduser'"
  end
end
