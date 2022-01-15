require "application_system_test_case"

class SchoolsTest < ApplicationSystemTestCase
  setup do
    @school = schools(:one)
  end

  test "visiting the index" do
    visit schools_url
    assert_selector "h1", text: "Schools"
  end

  test "should create school" do
    visit schools_url
    click_on "New school"

    fill_in "Area", with: @school.area_id
    fill_in "Bjg", with: @school.bjg
    fill_in "Category", with: @school.category
    fill_in "City", with: @school.city_id
    fill_in "Code", with: @school.code
    fill_in "County", with: @school.county_id
    fill_in "Jg", with: @school.jg
    fill_in "Lh", with: @school.lh
    fill_in "Name", with: @school.name
    fill_in "Qk", with: @school.qk
    fill_in "Total students", with: @school.total_students
    fill_in "Yx", with: @school.yx
    click_on "Create School"

    assert_text "School was successfully created"
    click_on "Back"
  end

  test "should update School" do
    visit school_url(@school)
    click_on "Edit this school", match: :first

    fill_in "Area", with: @school.area_id
    fill_in "Bjg", with: @school.bjg
    fill_in "Category", with: @school.category
    fill_in "City", with: @school.city_id
    fill_in "Code", with: @school.code
    fill_in "County", with: @school.county_id
    fill_in "Jg", with: @school.jg
    fill_in "Lh", with: @school.lh
    fill_in "Name", with: @school.name
    fill_in "Qk", with: @school.qk
    fill_in "Total students", with: @school.total_students
    fill_in "Yx", with: @school.yx
    click_on "Update School"

    assert_text "School was successfully updated"
    click_on "Back"
  end

  test "should destroy School" do
    visit school_url(@school)
    click_on "Destroy this school", match: :first

    assert_text "School was successfully destroyed"
  end
end
