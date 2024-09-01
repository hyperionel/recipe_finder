import React, { useState, useEffect } from "react";
import { useLocation } from "react-router-dom";
import IngredientList from "./IngredientList";
import RecipeList from "./RecipeList";
import AddIngredient from "./AddIngredient";
import SurpriseButton from "./SurpriseButton";

const RecipeFinder = () => {
  const [ingredients, setIngredients] = useState([]);
  const [recipes, setRecipes] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [highlightedIngredientIds, setHighlightedIngredientIds] = useState([]);
  const location = useLocation();

  useEffect(() => {
    const storedIngredients = JSON.parse(
      localStorage.getItem("ingredients") || "[]"
    );
    if (storedIngredients.length > 0) {
      setIngredients(storedIngredients);
    } else {
      fetchSurprise();
    }
  }, []);

  useEffect(() => {
    if (ingredients.length > 0) {
      fetchRecipes();
    }
  }, [ingredients, location]);

  const fetchSurprise = async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/v1/ingredients/surprise");
      const data = await response.json();
      setIngredients(data);
      localStorage.setItem("ingredients", JSON.stringify(data));
    } catch (error) {
      console.error("Error fetching surprise ingredients:", error);
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
                  <div className="mt-4">
                    <SurpriseButton onClick={fetchSurprise} />
                  </div>
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
                  <div className="mt-4">
                    <SurpriseButton onClick={fetchSurprise} />
                  </div>
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
