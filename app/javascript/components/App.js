import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import RecipeFinder from "./RecipeFinder";
import RecipeShow from "./RecipeShow";

const App = () => {
  return (
    <Router>
      <Routes>
        <Route exact path="/" element={<RecipeFinder />} />
        <Route path="/recipes/:id" element={<RecipeShow />} />
      </Routes>
    </Router>
  );
};

export default App;
