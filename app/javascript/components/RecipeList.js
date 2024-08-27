import React from "react";

const RecipeList = ({ recipes, isLoading, onRecipeHover, onRecipeLeave }) => {
  if (isLoading) {
    return (
      <div className="box scrollable-box">
        <h2 className="subtitle is-5">Recipes You Can Make</h2>
        <progress className="progress is-small is-primary" max="100">
          15%
        </progress>
      </div>
    );
  }

  return (
    <div className="box scrollable-box">
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
              <div className="card recipe-card">
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
              </div>
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
