require "application_system_test_case"

class ListsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    sign_in_as(@user)
    @list = lists(:one)
  end

  test "visiting the index" do
    visit lists_url
    assert_selector "h1", text: "Home"
  end

  test "should create list" do
    visit new_list_url

    fill_in "Start date", with: 7.days.from_now.to_date
    fill_in "End date", with: 14.days.from_now.to_date
    click_on "Create List"

    assert_selector "#list-items-section"
  end

  test "should destroy List" do
    visit list_url(@list)

    accept_confirm do
      click_on "Delete List", match: :first
    end

    assert_text "List was successfully deleted."
  end
end
