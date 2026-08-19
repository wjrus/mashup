require "application_system_test_case"

class InterfaceSystemTest < ApplicationSystemTestCase
  setup do
    user = users(:one)
    visit verify_login_path(token: user.generate_token_for(:email_login))
  end

  test "account menu and theme picker work" do
    find("summary[aria-label='Account menu']").click

    assert_text users(:one).email
    assert_button "Sign out"

    select "Paper", from: "Theme"

    assert_equal "paper", page.evaluate_script("document.documentElement.dataset.theme")
    assert_equal "paper", page.evaluate_script("document.documentElement.dataset.themeChoice")
  end

  test "destructive action uses the custom dialog and timed dismissible flash" do
    space = Space.create!(name: "Temporary room")
    visit admin_spaces_path

    within("tr", text: space.name) do
      click_button "Delete"
    end

    assert_selector "dialog[open]"
    assert_text "Delete Temporary room? This cannot be undone."
    assert_raises(Selenium::WebDriver::Error::NoSuchAlertError) do
      page.driver.browser.switch_to.alert.text
    end

    click_button "Cancel"
    assert_no_selector "dialog[open]"
    assert Space.exists?(space.id)

    within("tr", text: space.name) do
      click_button "Delete"
    end
    within("dialog[open]") do
      click_button "Delete space"
    end

    assert_text "Space deleted."
    assert_no_text "Temporary room"
    assert_selector ".flash-progress[data-dismissible-target='progress']", visible: :all

    find("button[aria-label='Dismiss message']").click
    assert_no_selector ".flash"
  end
end
