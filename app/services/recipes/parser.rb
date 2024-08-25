module Recipes
  class Parser
    def initialize(language = :en)
      @normalizer = "Recipes::#{language.to_s.capitalize}::Normalizer".constantize.new
    end

    def parse_ingredient(ingredient_string)
      @normalizer.normalize(ingredient_string)
    end
  end
end
