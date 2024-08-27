import React, { useState, useEffect } from "react";
import IngredientList from "./IngredientList";
import RecipeList from "./RecipeList";
import AddIngredient from "./AddIngredient";

const App = () => {
  const [ingredients, setIngredients] = useState([]);
  const [recipes, setRecipes] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [highlightedIngredientIds, setHighlightedIngredientIds] = useState([]);

  useEffect(() => {
    const storedIngredients = JSON.parse(
      localStorage.getItem("ingredients") || "[]"
    );
    if (storedIngredients.length > 0) {
      setIngredients(storedIngredients);
    } else {
      fetchIngredients();
    }
  }, []);

  useEffect(() => {
    if (ingredients.length > 0) {
      fetchRecipes();
    }
  }, [ingredients]);

  const fetchIngredients = async () => {
    const response = await fetch("/api/v1/ingredients");
    const data = await response.json();
    setIngredients(data);
    localStorage.setItem("ingredients", JSON.stringify(data));
  };

  const fetchRecipes = async () => {
    setIsLoading(true);
    const ingredientIds = ingredients.map((ing) => ing.id).join(",");
    const response = await fetch(
      `/api/v1/recipes?ingredient_ids=${ingredientIds}`
    );
    const data = await response.json();
    setRecipes(data);
    setIsLoading(false);
  };

  const addIngredient = (ingredient) => {
    const updatedIngredients = [...ingredients, ingredient];
    setIngredients(updatedIngredients);
    localStorage.setItem("ingredients", JSON.stringify(updatedIngredients));
  };

  const removeIngredient = (id) => {
    const updatedIngredients = ingredients.filter((ing) => ing.id !== id);
    setIngredients(updatedIngredients);
    localStorage.setItem("ingredients", JSON.stringify(updatedIngredients));
  };

  const handleRecipeHover = (recipeIngredients) => {
    setHighlightedIngredientIds(recipeIngredients.map((ing) => ing.id));
  };

  const handleRecipeLeave = () => {
    setHighlightedIngredientIds([]);
  };

  return (
    <div className="full-height-container">
      <h1 className="title is-4">Recipe Finder</h1>
      <div className="full-height-columns columns">
        <div className="column is-two-fifths scrollable-column">
          <div className="box scrollable-box">
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
          </div>
        </div>
        <div className="column is-three-fifths scrollable-column">
          <RecipeList
            recipes={recipes}
            isLoading={isLoading}
            onRecipeHover={handleRecipeHover}
            onRecipeLeave={handleRecipeLeave}
          />
        </div>
      </div>
    </div>
  );
};

export default App;
