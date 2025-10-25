require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user with valid params" do
    assert_difference("User.count", 1) do
      post users_url, params: {
        user: {
          first_name: "John",
          last_name: "Doe",
          email_address: "john@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Welcome!", flash[:notice]

    # Check user was logged in
    assert_not_nil cookies[:session_id]
  end

  test "should create personal group when user signs up" do
    assert_difference("Group.count", 1) do
      post users_url, params: {
        user: {
          first_name: "John",
          last_name: "Doe",
          email_address: "john@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.last
    assert_equal 1, user.groups.count
    assert_equal "John Doe", user.groups.first.name
  end

  test "should not create user with invalid params" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          first_name: "",
          last_name: "Doe",
          email_address: "john@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user when passwords do not match" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          first_name: "John",
          last_name: "Doe",
          email_address: "john@example.com",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with duplicate email" do
    User.create!(
      first_name: "Jane",
      last_name: "Doe",
      email_address: "john@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          first_name: "John",
          last_name: "Doe",
          email_address: "john@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
