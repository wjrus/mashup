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

  test "keyboard users can skip navigation and manage dynamic contact rows" do
    visit edit_patron_path(patrons(:one))

    find("body").send_keys(:tab)
    assert_equal "Skip to main content", page.evaluate_script("document.activeElement.textContent.trim()")
    find(".skip-link").send_keys(:enter)
    assert_equal "main-content", page.evaluate_script("document.activeElement.id")

    click_button "Add contact"
    assert_selector "[role='status']", text: "Contact added.", visible: :all
    assert_match(/first_name\z/, page.evaluate_script("document.activeElement.id"))

    within all("[data-nested-form-row]").last do
      click_button "Remove contact"
    end
    within("dialog[open]") do
      click_button "Remove contact"
    end

    assert_selector "[role='status']", text: "Contact removed.", visible: :all
    assert_equal "Remove contact", page.evaluate_script("document.activeElement.textContent.trim()")
  end

  test "validation errors receive focus and describe invalid fields" do
    visit new_admin_space_path
    page.execute_script("document.querySelector('#space_name').removeAttribute('required')")
    fill_in "Capacity", with: "1"
    click_button "Create Space"

    assert_selector ".error-summary:focus"
    assert_selector "#space_name[aria-invalid='true'][aria-describedby='space_name_error']"
    assert_text "Name can't be blank"
  end

  test "destructive action uses the custom dialog and timed dismissible flash" do
    space = Space.create!(name: "Temporary room")
    visit admin_spaces_path

    page.current_window.resize_to(390, 844)
    assert_operator page.evaluate_script("document.documentElement.scrollWidth"), :<=,
      page.evaluate_script("window.innerWidth")
    page.current_window.resize_to(1280, 900)

    within("tr", text: space.name) do
      edit_button = find("a", text: "Edit")
      delete_button = find_button("Delete")

      assert_operator edit_button.rect.height, :<=, 36
      assert_in_delta edit_button.rect.height, delete_button.rect.height, 1
      assert_in_delta edit_button.rect.y, delete_button.rect.y, 1
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
