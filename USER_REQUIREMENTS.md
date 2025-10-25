# As a user visiting the index page
- As a user I want to visit the index page and see the current list
- As a user I want to be able to edit the current list from the index page
- As a user I expect my list items to always be in the same order when I return to the page
- As a user, editing the current list means one or more of the following: changing list item names, updating list item quantities, adding list items (default quantity = 1), removing list items, reordering list items, changing meal names
- As a user, I expect my list items to automatically go into the correct ordering based on previous ordering
- As the developer, when a list item's name is changed to one not in the database, create a new list item and attach it to the current list in the same position
- As the developer we should order all list items by user preference and keep the ordering. If the user reorders the list, update that item's order and bump all following item orders by 1
- As the developer we need to use a decimal/fractional ordering algorithm. When we reorder a list item, we calculate its sort_order as the midpoint between the previous and next items (e.g., if moving between items with order 1.0 and 2.0, the new order would be 1.5). This avoids having to update all following items.
- As a user, I expect suggestions when typing to add list items, for example if I type 'mil' I expect 'milk' to be suggested
- As a user, I expect suggestions when typing meals, for example if I start typing 'spa', I expect 'spaghetti' and 'spanish omelette' to be suggested
- As a user, when I edit text on a list item, I expect to click a button to confirm the change
- As a user, I expect the list to auto-save after each action (add, remove, reorder, quantity change)
- As a user I want to be able to click a button to add add a new list
- As a user I want to be able to click a button to see a list of previous lists

# As a user creating a new list
- As a user I expect to be able to set the shopping date and the number of days I am shopping for
- As a user I expect the default shopping date to be today and the number of days to be a week, eg Thursday, Friday, Saturday, Sunday, Monday, Tuesday, Wednesday
- As a user, once I have created a list I expect to be taken to the index page to start editing it
- As a user, once I have created a new list, it becomes the current list (the most recent list for my group)

# Groups and Multi-Tenancy
- As a user, when I create an account, a group is automatically created with my name
- As the developer, when a user signs up (e.g., "Jon"), create a group named "Jon" and add the user to it
- As a user, I can create additional groups with any name and invite other users to join
- As a user, I can be part of multiple groups (my initial group + any groups I create or am invited to)
- As a user, I can switch between viewing different groups' data
- As a user, when viewing a specific group, I can only see and interact with that group's lists, items, and meals
- As a user, I cannot see or access lists, items, or meals from groups I'm not a member of
- As the developer, all lists, items, and meals must be scoped to a group
- As the developer, a group has many users through a UserGroup join table
- As the developer, items are group-specific (not shared across groups)
- As the developer, meals are group-specific (not shared across groups)
- Example: Jon signs up → "Jon" group created. Beth signs up → "Beth" group created. Jon invites Beth to the "Jon" group. Beth can now switch between viewing "Beth" group data and "Jon" group data. Jon creates a "Clarke" group and invites Beth. Both can now switch between "Jon", "Beth", and "Clarke" groups.

## MVP
- Create a list
    - Sets Saturday -> Saturday only
    - New list becomes the current list (most recent)
- Edit the list from the index page
    - Includes quantities (default quantity = 1)
    - No suggestions for meals or list items
    - No auto-ordering

## Technical Notes
- **Current List**: The current list is `current_group.lists.last` (scoped to the active group)
- **Current Group**: Stored in session; user can switch between groups they belong to
- **Data Models**:
  - `Group`: id, name
  - `User`: has many Groups through UserGroups (many-to-many relationship)
  - `UserGroup`: Junction table - user_id, group_id (allows users to be in multiple groups)
  - `List`: belongs to Group (via group_id foreign key), has date
  - `Item`: belongs to Group (via group_id foreign key), master list of all possible items for that group
  - `ListItem`: belongs to List and Item, has quantity and sort_order (decimal)
  - `Meal`: belongs to Group (via group_id foreign key), separate table for meals
  - `ListMeal`: Junction table - belongs to List and Meal
- **Group Creation**: When a user signs up, automatically create a group with their name and add them to it via UserGroups
- **Auto-save**: List auto-saves after each action, except text editing which requires explicit confirmation button
- **Ordering**: ListItems use decimal/fractional sort_order (precision: 15, scale: 5) for efficient reordering

## Routing

### Display Routes
```ruby
root 'lists#show'                    # Shows List.last with items AND meals
get  '/new', to: 'lists#new'         # List creation form
get  '/lists', to: 'lists#index'     # All lists
get  '/lists/:id', to: 'lists#show'  # View a specific list (with items and meals)
```

### Create List
```ruby
post '/lists', to: 'lists#create'    # Creates new list (becomes current list)
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
