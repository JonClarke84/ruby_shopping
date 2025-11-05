require "application_system_test_case"

class ListsTest < ApplicationSystemTestCase
  setup do
    @list = lists(:one)
  end

  test "visiting the index" do
    visit lists_url
    assert_selector "h1", text: "Shopping list for"
  end

  test "should create list" do
    visit new_list_url

    fill_in "list_date", with: 7.days.from_now
    click_on "Create"

    assert_selector "h1", text: "Shopping list for"
  end

  test "should destroy List" do
    visit list_url(@list)

    accept_confirm do
      click_on "Destroy this list", match: :first
    end

    assert_text "List was successfully destroyed"
  end
end
