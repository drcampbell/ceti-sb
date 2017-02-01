require 'test_helper'
 
class PostTest < ActionDispatch::IntegrationTest
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "should get index" do
    get "/"
    assert_response :success
  end
end
