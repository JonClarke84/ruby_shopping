# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

puts "Seeding data..."

# Create a main user
user = User.find_or_initialize_by(email_address: "one@example.com")
user.update!(
  first_name: "Test",
  last_name: "User",
  password: "password",
  password_confirmation: "password"
)

# Create another user for invitations
other_user = User.find_or_initialize_by(email_address: "two@example.com")
other_user.update!(
  first_name: "Another",
  last_name: "User",
  password: "password",
  password_confirmation: "password"
)

# Find the default group created by the after_create callback
main_group = user.groups.first
main_group.update!(name: "Main Family Group")

# Ensure other_user is also in the group
main_group.users << other_user unless main_group.users.include?(other_user)

# Create some items
items = [
  "Milk", "Bread", "Eggs", "Apples", "Bananas",
  "Chicken Breast", "Pasta", "Tomato Sauce", "Coffee", "Tea"
].map do |name|
  Item.find_or_create_by!(name: name, group_id: main_group.id)
end

# Create a current list
list = List.find_or_create_by!(
  group_id: main_group.id,
  date: Date.today.beginning_of_week
) do |l|
  l.end_date = Date.today.end_of_week
end

# Add some items to the list
items.first(5).each do |item|
  ListItem.find_or_create_by!(list_id: list.id, item_id: item.id) do |li|
    li.quantity = rand(1..3)
  end
end

# Add some meals
meals = [ "Spaghetti", "Roast Chicken", "Salad", "Tacos", "Stir Fry" ].map do |name|
  Meal.find_or_create_by!(name: name, group_id: main_group.id)
end

# Assign meals to dates in the list
list.date_range.to_a.first(meals.length).each_with_index do |date, i|
  ListMeal.find_or_create_by!(list_id: list.id, date: date) do |lm|
    lm.meal = meals[i]
  end
end

# Set user's group selection
UserGroupSelection.find_or_create_by!(user: user) do |ugs|
  ugs.group = main_group
end

puts "Seeding completed successfully!"
