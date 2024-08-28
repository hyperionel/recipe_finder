import React, { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";

const RecipeShow = () => {
  const [recipe, setRecipe] = useState(null);
  const { id } = useParams();

  useEffect(() => {
    const fetchRecipe = async () => {
      const response = await fetch(`/api/v1/recipes/${id}`);
      const data = await response.json();
      setRecipe(data);
    };
    fetchRecipe();
  }, [id]);

  if (!recipe) return <div>Loading...</div>;

  return (
    <div className="container mt-5">
      <Link to="/" className="button is-light mb-3">
        Back to Recipes
      </Link>
      <div className="box">
        <h1 className="title">{recipe.title}</h1>
        <p className="subtitle">
          By {recipe.author ? recipe.author.name : "Unknown"} | Category:{" "}
          {recipe.category ? recipe.category.name : "Uncategorized"}
        </p>
        <div className="content">
          <p>Cook Time: {recipe.cook_time} minutes</p>
          <p>Prep Time: {recipe.prep_time} minutes</p>
          <h2 className="subtitle">Ingredients:</h2>
          <ul>
            {recipe.ingredient_data.map((item, index) => (
              <li key={index}>{item}</li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default RecipeShow;
