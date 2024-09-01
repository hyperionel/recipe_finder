### Instructions

```
  rails db:create db:migrate

  rake recipes:import_data

```

### URL
https://recipe-finder.fly.dev/

## Penny Lane App case study

### User stories

Based on the data and the problem statement, we identify a few user stories:
 - the user should be able to provide a list of ingredients and the application should return a list of recipes based on those ingredients
	 - meaning the user should have the ability to add and remove ingredients and the recipe recommendations should update when they do this
 - given a list of ingredients find the most relevant(based on rating?) recipes for those ingredients

After looking at the data and the structure of the ingredient names I explored the following 2 scenarios:

### #1 Exploration - with Ingredient quantity and unit type (out of scope and not feasible)

Trying to extract ingredient quantities and unit types proved to be difficult due to the amount of unit types and the lack of a sufficiently good standard present in the ingredient title for a lot of ingredients. 

We wouldn't have been able to extract the quantity and unit types reliably without having way too much hardcoding & mapping.

### #2 Exploration - Normalize ingredient titles to remove quantities and unnecessary information

Went with this approach along with saving another original copy of the ingredients on the recipes table in order to display to the user on the individual recipe card.

### Other features

#### Importer/Parser/Normalizer
- batch imports
- ability to extend to multiple language formats

#### IngredientsController
- when building the payload for random ingredients we make sure we select ingredients that contain a minimum of 4 recipes (because pressing randomize until I got one was getting boring)
- ordered autocompleted using pg_trgm based on similarity and length

#### RecipesController
- recipes endpoint only fetch recipes where all their ingredients are included by ingredient_ids received in params

#### React FE
- dynamic components that automatically refetch + re-render whenever an ingredient is added/removed
