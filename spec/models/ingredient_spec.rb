require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe 'associations' do
    it { should have_many(:recipe_ingredients) }
    it { should have_many(:recipes).through(:recipe_ingredients) }
  end

  describe 'validations' do
    subject { build(:ingredient) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
end
