require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'associations' do
    it { should have_many(:recipes) }
  end

  describe 'validations' do
    subject { build(:author) }

    it { should validate_presence_of(:name) }
  end
end
