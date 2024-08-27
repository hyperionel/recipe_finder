import React from "react";

const IngredientList = ({
  ingredients,
  onRemove,
  highlightedIngredientIds,
}) => {
  return (
    <div>
      <h2 className="subtitle">Available Ingredients</h2>
      <div className="tags are-medium">
        {ingredients.map((ingredient) => (
          <span
            key={ingredient.id}
            className={`tag ${
              highlightedIngredientIds.includes(ingredient.id)
                ? "is-success"
                : "is-info"
            } is-light`}
          >
            {ingredient.name}
            <button
              className="delete is-small"
              onClick={() => onRemove(ingredient.id)}
            ></button>
          </span>
        ))}
      </div>
    </div>
  );
};

export default IngredientList;
