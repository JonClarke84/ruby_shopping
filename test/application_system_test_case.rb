require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Increase wait time for slower CI/local runs
  Capybara.default_max_wait_time = 10

  def sign_in_as(user, password: "password")
    sleep 0.5
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button "Sign in"
    assert_selector "h1", text: "Home"
  end
end
