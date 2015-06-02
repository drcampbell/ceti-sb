require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase

  pname = "The School Business App"
  
  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Help | #{pname}"
  end
  
  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "About | #{pname}"
  end
  
  # test "should get contact" do
  #   get :contact
  #   assert_response :success
  #   assert_select "title", "Contact | #{pname}"
  # end
  
end
