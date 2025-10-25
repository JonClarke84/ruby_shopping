require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create user with valid attributes" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user.save
  end

  test "should require first name" do
    user = User.new(
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123"
    )
    assert_not user.save
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "should require last name" do
    user = User.new(
      first_name: "John",
      email_address: "john@example.com",
      password: "password123"
    )
    assert_not user.save
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "should require email address" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      password: "password123"
    )
    assert_not user.save
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should require unique email address" do
    User.create!(
      first_name: "Jane",
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123"
    )

    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123"
    )
    assert_not user.save
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "should require password" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email_address: "john@example.com"
    )
    assert_not user.save
  end

  test "should require password confirmation to match" do
    user = User.new(
      first_name: "John",
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123",
      password_confirmation: "different"
    )
    assert_not user.save
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "should have many user_groups" do
    assert_respond_to User.new, :user_groups
  end

  test "should have many groups through user_groups" do
    assert_respond_to User.new, :groups
  end

  test "should create personal group on user creation" do
    user = User.create!(
      first_name: "John",
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_equal 1, user.groups.count
    assert_equal "John Doe", user.groups.first.name
  end

  test "should destroy user_groups when user is destroyed" do
    user = User.create!(
      first_name: "John",
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    user_group_id = user.user_groups.first.id
    user.destroy

    assert_nil UserGroup.find_by(id: user_group_id)
  end
end
