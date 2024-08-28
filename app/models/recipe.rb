class Recipe < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :author, optional: true
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true
  validates :cook_time, :prep_time, numericality: { greater_than_or_equal_to: 0 }

  store_accessor :ingredient_data
end
