import React from "react";
import { Link } from "react-router-dom";

const RecipeList = ({ recipes, isLoading, onRecipeHover, onRecipeLeave }) => {
  if (isLoading) {
    return (
      <div className="box">
        <h2 className="subtitle is-5">Recipes You Can Make</h2>
        <progress className="progress is-small is-primary" max="100">
          15%
        </progress>
      </div>
    );
  }

  const getImageUrl = (imageString) => {
    try {
      const url = new URL(imageString);
      return url.searchParams.get("url") || "";
    } catch {
      return "";
    }
  };

  return (
    <div className="box">
      <h2 className="subtitle is-5">Recipes You Can Make</h2>
      {recipes.length > 0 ? (
        <div className="columns is-multiline">
          {recipes.map((recipe) => (
            <div
              key={recipe.id}
              className="column is-6"
              onMouseEnter={() => onRecipeHover(recipe.ingredients)}
              onMouseLeave={onRecipeLeave}
            >
              <Link
                to={`/recipes/${recipe.id}`}
                className="card recipe-card has-background-link"
              >
                <div
                  className="recipe-card-background"
                  style={{
                    backgroundImage: `url(${getImageUrl(recipe.image)})`,
                  }}
                ></div>
                <div className="card-content">
                  <p className="title is-5">{recipe.title}</p>
                  <p className="subtitle is-6">
                    {recipe.author ? recipe.author.name : "Unknown"} |
                    {recipe.category ? recipe.category.name : "Uncategorized"}
                  </p>
                  <div className="content">
                    <p>
                      Cook: {recipe.cook_time}m | Prep: {recipe.prep_time}m
                    </p>
                  </div>
                </div>
              </Link>
            </div>
          ))}
        </div>
      ) : (
        <p>No recipes found with current ingredients.</p>
      )}
    </div>
  );
};

export default RecipeList;
