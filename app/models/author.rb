class Author < ApplicationRecord
  has_many :recipes

  validates :name, presence: true, uniqueness: true, unless: -> { name == "deleteduser" }
end
