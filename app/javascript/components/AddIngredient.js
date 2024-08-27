import React, { useState, useEffect } from "react";

const AddIngredient = ({ onAdd }) => {
  const [name, setName] = useState("");
  const [suggestions, setSuggestions] = useState([]);

  useEffect(() => {
    if (name.length >= 3) {
      fetchSuggestions();
    } else {
      setSuggestions([]);
    }
  }, [name]);

  const fetchSuggestions = async () => {
    const response = await fetch(`/api/v1/ingredients?query=${name}`);
    const data = await response.json();
    setSuggestions(data);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (name.trim()) {
      addIngredient({ id: Date.now(), name: name.trim() });
    }
  };

  const handleSuggestionClick = (suggestion) => {
    addIngredient(suggestion);
  };

  const addIngredient = (ingredient) => {
    onAdd(ingredient);
    setName("");
    setSuggestions([]);
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && suggestions.length > 0) {
      e.preventDefault();
      addIngredient(suggestions[0]);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="field">
        <div className="control">
          <input
            className="input"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Add ingredient"
          />
        </div>
      </div>
      {suggestions.length > 0 && (
        <div className="dropdown is-active">
          <div className="dropdown-menu">
            <div className="dropdown-content">
              {suggestions.map((suggestion) => (
                <a
                  key={suggestion.id}
                  className="dropdown-item"
                  onClick={() => handleSuggestionClick(suggestion)}
                >
                  {suggestion.name}
                </a>
              ))}
            </div>
          </div>
        </div>
      )}
      {name.length >= 3 && suggestions.length === 0 && (
        <div className="dropdown is-active">
          <div className="dropdown-menu">
            <div className="dropdown-content">
              <div className="dropdown-item">No matches found</div>
            </div>
          </div>
        </div>
      )}
    </form>
  );
};

export default AddIngredient;
