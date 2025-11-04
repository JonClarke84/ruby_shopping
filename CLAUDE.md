# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.1 shopping list application with multi-tenancy support via Groups. Users can create and manage shopping lists with items and meals, organized by groups they belong to.

**Technology Stack:**
- Ruby 3.3.6
- Rails 8.1.1
- SQLite3
- Hotwire (Turbo + Stimulus)
- Authentication via bcrypt (has_secure_password)
- Rubocop (Rails Omakase styling)

## Development Commands

### Running the Application
```bash
bin/rails server          # Start server on default port (3000)
bin/setup                 # Initial setup: install dependencies, setup database
```

### Testing
```bash
bin/rails test                    # Run all tests
bin/rails test test/models        # Run model tests only
bin/rails test test/controllers   # Run controller tests only
bin/rails test:system             # Run system tests
bin/rails test <path_to_test>     # Run a single test file
```

### Linting
```bash
bundle exec rubocop               # Check code style
bundle exec rubocop -a            # Auto-correct violations
```

### Database
```bash
bin/rails db:migrate              # Run pending migrations
bin/rails db:reset                # Drop, create, migrate, and seed database
bin/rails db:schema:load          # Load schema without running migrations
```

## Architecture

### Multi-Tenancy via Groups

This application implements multi-tenancy through a Group-based system where all data is scoped to groups:

- **Groups**: Central tenant entity. Users belong to multiple groups via many-to-many relationship
- **Session-based Group Selection**: Active group stored in `Session.selected_group_id`, accessible via `Current.session.selected_group`
- **Data Isolation**: Lists, Items, and Meals all belong to a Group and must be scoped appropriately
- **Automatic Group Creation**: When users sign up, a default group is created with their full name

**Key Pattern - current_group helper:**
Controllers define a `current_group` helper method that returns:
```ruby
Current.session&.selected_group || Group.find_by(name: "Test Group") || Group.first
```

This pattern allows tests to work without authentication while providing proper group scoping in production.

### Authentication & Current Context

Authentication is handled via the `Authentication` concern included in `ApplicationController`:
- Session stored in signed, permanent cookies (`session_id`)
- Current user and session available via `Current.session` and `Current.user`
- `Current` uses `ActiveSupport::CurrentAttributes` for request-scoped storage
- Tests automatically set `Current.session = sessions(:one)` in test_helper.rb

### Core Data Models

**Multi-Tenancy Layer:**
- `Group`: The tenant entity (has many users, lists, items, meals)
- `UserGroup`: Join table for users ↔ groups (many-to-many)
- `UserGroupSelection`: Stores user's last selected group for persistence
- `Session`: Stores `selected_group_id` for current session

**Shopping List Domain:**
- `List`: belongs to Group, has date
- `Item`: belongs to Group (master list of all items for that group)
- `ListItem`: Join table with quantity and decimal sort_order for fractional ordering
- `Meal`: belongs to Group
- `ListMeal`: Join table with date field

**Important:** The "current list" is always `current_group.lists.last` - the most recently created list for the active group.

### Decimal/Fractional Ordering

`ListItem.sort_order` uses decimal ordering (precision: 15, scale: 5) to efficiently reorder items:
- When moving an item between positions, calculate midpoint: `(prev_order + next_order) / 2`
- Example: Moving between items with order 1.0 and 2.0 → new order is 1.5
- This avoids updating all following items when reordering

### Authorization Pattern

Controllers use `before_action :authorize_<resource>` to verify group access:
```ruby
def authorize_list
  unless @list && @list.group_id == current_group.id
    redirect_to root_path, alert: "You don't have access to that list"
  end
end
```

Always check that resources belong to `current_group` before allowing access.

### Routing Structure

- Root: `lists#index` - shows current list (`current_group.lists.last`)
- Nested resources: `lists/:list_id/items` and `lists/:list_id/meals`
- Group switching: `PATCH /switch_group` updates session's selected_group
- Group invitations: `GET /groups/:id/invite` and `POST /groups/:id/invite`

## Testing Conventions

- All tests inherit from `ActiveSupport::TestCase`
- Tests run in parallel by default (`parallelize(workers: :number_of_processors)`)
- Fixtures in `test/fixtures/*.yml` loaded for all tests
- `Current.session` automatically set to `sessions(:one)` in setup
- Controllers skip authentication in test environment: `skip_before_action :require_authentication if Rails.env.test?`

### Manual Test Users

The following test users are available for manual testing:

| Name | Email | Password | Default Group |
|------|-------|----------|---------------|
| Alice Smith | alice@example.com | password123 | Alice Smith |
| Bob Jones | bob@example.com | password123 | Bob Jones |

These users can be used to test:
- Group invitations (Alice inviting Bob or vice versa)
- Multi-user group membership
- Leave group functionality
- Group switching between different users' groups

## Important Implementation Notes

1. **Always scope queries to current_group:**
   - Use `current_group.lists`, `current_group.items`, `current_group.meals`
   - Never query these models directly without group scoping

2. **Group creation on user signup:**
   - User model has `after_create :create_default_group` callback
   - Automatically creates group named with user's full name

3. **Test environment fallbacks:**
   - Many controllers have `current_group` fallback: `Group.find_by(name: "Test Group") || Group.first`
   - This allows tests to work without full authentication setup

4. **Current list retrieval:**
   - Always use `current_group.lists.last` to get the current/active list
   - Never store "current list ID" in session

5. **Authorization checks:**
   - Always verify `resource.group_id == current_group.id` before allowing access
   - Use `before_action :authorize_<resource>` pattern consistently
