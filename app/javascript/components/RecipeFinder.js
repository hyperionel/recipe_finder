import React, { useState, useEffect } from "react";
import IngredientList from "./IngredientList";
import RecipeList from "./RecipeList";
import AddIngredient from "./AddIngredient";

const RecipeFinder = () => {
  const [ingredients, setIngredients] = useState([]);
  const [recipes, setRecipes] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [highlightedIngredientIds, setHighlightedIngredientIds] = useState([]);

  useEffect(() => {
    fetchIngredients();
  }, []);

  useEffect(() => {
    if (ingredients.length > 0) {
      fetchRecipes();
    }
  }, [ingredients]);

  const fetchIngredients = async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/v1/ingredients");
      const data = await response.json();
      setIngredients(data);
    } catch (error) {
      console.error("Error fetching ingredients:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const fetchRecipes = async () => {
    setIsLoading(true);
    const ingredientIds = ingredients.map((ing) => ing.id).join(",");
    try {
      const response = await fetch(
        `/api/v1/recipes?ingredient_ids=${ingredientIds}`
      );
      const data = await response.json();
      setRecipes(data);
    } catch (error) {
      console.error("Error fetching recipes:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const addIngredient = (ingredient) => {
    setIngredients([...ingredients, ingredient]);
  };

  const removeIngredient = (id) => {
    setIngredients(ingredients.filter((ing) => ing.id !== id));
  };

  const handleRecipeHover = (recipeIngredients) => {
    setHighlightedIngredientIds(recipeIngredients.map((ing) => ing.id));
  };

  const handleRecipeLeave = () => {
    setHighlightedIngredientIds([]);
  };

  return (
    <div className="content-wrapper">
      <div className="container">
        <h1 className="title is-2 has-text-centered has-text-black">
          Recipe Finder
        </h1>
        <div className="columns">
          <div className="column is-two-fifths">
            <div className="box">
              {ingredients.length > 0 ? (
                <>
                  <IngredientList
                    ingredients={ingredients}
                    onRemove={removeIngredient}
                    highlightedIngredientIds={highlightedIngredientIds}
                  />
                  <div className="mt-4">
                    <AddIngredient onAdd={addIngredient} />
                  </div>
                  <button
                    className="button is-primary is-fullwidth mt-4"
                    onClick={fetchIngredients}
                  >
                    Randomize Ingredients
                  </button>
                </>
              ) : (
                <div className="placeholder-container">
                  <span className="icon placeholder-icon">
                    <i className="fas fa-utensils"></i>
                  </span>
                  <p className="placeholder-text">
                    No ingredients yet. Start by adding some!
                  </p>
                  <div className="mt-4">
                    <AddIngredient onAdd={addIngredient} />
                  </div>
                  <button
                    className="button is-primary is-fullwidth mt-4"
                    onClick={fetchIngredients}
                  >
                    Get Random Ingredients
                  </button>
                </div>
              )}
            </div>
          </div>
          <div className="column is-three-fifths">
            <RecipeList
              recipes={recipes}
              isLoading={isLoading}
              onRecipeHover={handleRecipeHover}
              onRecipeLeave={handleRecipeLeave}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default RecipeFinder;
