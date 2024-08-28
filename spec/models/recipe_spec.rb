require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'associations' do
    it { should belong_to(:category).optional }
    it { should belong_to(:author).optional }
    it { should have_many(:recipe_ingredients) }
    it { should have_many(:ingredients).through(:recipe_ingredients) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_numericality_of(:cook_time).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:prep_time).is_greater_than_or_equal_to(0) }
  end

  describe 'store_accessor' do
    it { should respond_to(:ingredient_data) }
  end
end
