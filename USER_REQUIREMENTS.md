# As a user visiting the index page
As a user I want to visit the index page and see the current list
As a user I want to be able to edit the current list from the index page 
As a user I expect my list items to always be in the same order when I return to the page
As a user, editing the current list means one or more of the following: changing list item names, updating list item quantities, adding list items (default quantity = 1), removing list items, reordering list items, changing meal names
As a user, I expect my list items to automatically go into the correct ordering based on previous ordering
As the developer, when a list item's name is changed to one not in the database, create a new list item and attach it to the current list in the same position
As the developer we should order all list items by user preference and keep the ordering. If the user reorders the list, update that item's order and bump all following item orders by 1
As the developer we need to use a decimal/fractional ordering algorithm. When we reorder a list item, we calculate its sort_order as the midpoint between the previous and next items (e.g., if moving between items with order 1.0 and 2.0, the new order would be 1.5). This avoids having to update all following items.
As a user, I expect suggestions when typing to add list items, for example if I type 'mil' I expect 'milk' to be suggested
As a user, I expect suggestions when typing meals, for example if I start typing 'spa', I expect 'spaghetti' and 'spanish omelette' to be suggested
As a user, when I edit text on a list item, I expect to click a button to confirm the change
As a user, I expect the list to auto-save after each action (add, remove, reorder, quantity change)
As a user I want to be able to click a button to add add a new list
As a user I want to be able to click a button to see a list of previous lists

# As a user creating a new list
As a user I expect to be able to set the shopping date and the number of days I am shopping for
As a user I expect the default shopping date to be today and the number of days to be a week, eg Thursday, Friday, Saturday, Sunday, Monday, Tuesday, Wednesday
As a user, once I have created a list I expect to be taken to the index page to start editing it
As a user, once I have created a list I expect the current list to be archived

## MVP
- Create a list
    - Sets Saturday -> Saturday only
    - Archives current list
- Edit the list from the index page
    - Includes quantities (default quantity = 1)
    - No suggestions for meals or list items
    - No auto-ordering

## Technical Notes
- **Current List**: The current list is simply `List.last`
- **Data Models**:
  - `Item`: Master list of all possible items
  - `ListItem`: An instance of an Item on a specific List
  - `Meal`: Separate table for meals
  - `ListMeal`: Junction table - a List has many ListMeals
- **Auto-save**: List auto-saves after each action, except text editing which requires explicit confirmation button

## Routing

### Display Routes
```ruby
root 'lists#show'                    # Shows List.last with items AND meals
get  '/new', to: 'lists#new'         # List creation form
get  '/lists', to: 'lists#index'     # All lists
get  '/lists/:id', to: 'lists#show'  # View a specific list (with items and meals)
```

### Create/Archive List
```ruby
post '/lists', to: 'lists#create'    # Creates new list, archives current
```

### List Items (auto-save except text edits)
```ruby
post   '/lists/:list_id/list_items', to: 'list_items#create'           # Add item (auto-save)
patch  '/lists/:list_id/list_items/:id', to: 'list_items#update'       # Update name (confirm button) or quantity (auto-save)
delete '/lists/:list_id/list_items/:id', to: 'list_items#destroy'      # Remove item (auto-save)
patch  '/lists/:list_id/list_items/:id/reorder', to: 'list_items#reorder'  # Reorder item (auto-save, post-MVP)
```

### List Meals (auto-save except text edits)
```ruby
post   '/lists/:list_id/list_meals', to: 'list_meals#create'          # Add meal (auto-save)
patch  '/lists/:list_id/list_meals/:id', to: 'list_meals#update'      # Update meal name (confirm button)
delete '/lists/:list_id/list_meals/:id', to: 'list_meals#destroy'     # Remove meal (auto-save)
```
