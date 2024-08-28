module Recipes
  module En
    class Normalizer
      UNITS_OF_MEASURE = [
        "cup", "cups", "teaspoon", "teaspoons", "tablespoon", "tablespoons", "slice", "slices",
        "package", "packages", "ounce", "ounces", "gram", "grams", "stalks", "head", "pounds", "pound",
        "clove", "drops", "pinches", "pinch", "bunch", "each", "can", "cans"
      ].freeze

      SIZES = [ "small", "medium", "large" ].freeze

      def normalize(ingredient_string)
        ingredient_string
          .gsub(/^\W+/, "")  # Remove any non-letter chars at the beginning of the string
          .gsub(/[\(\)]/, "")
          .gsub(/\s-\s.*$/, "")
          .gsub(/\d+(\s*\/\s*\d+)?/, "")  # Remove numbers and fractions
          .gsub(/[¼½¾⅐⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞]/, "")  # Remove unicode fractions
          .gsub(/,.*$/, "")  # Remove everything after a comma
          .strip
          .downcase
          .gsub(/\b(#{(UNITS_OF_MEASURE + SIZES).join('|')})\b/, "")  # Remove standalone units and sizes
          .gsub(/\s+/, " ")  # Replace multiple spaces with a single space
          .strip  # Remove leading and trailing spaces
      end
    end
  end
end
