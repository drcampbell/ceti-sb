require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "login and browse site" do
    https!
    get "/users/sign_in"
    assert_response :success

    # Handle case where user can't sign in    
    post_via_redirect "/users/sign_in",
		      user: {
			email: '',
		      }
    assert_equal "/users/sign_in", path
    assert_equal I18n.t(:invalid_email_or_password), flash[:danger]
	
    # Handle case where user signs in successfully    
    post_via_redirect "/users/sign_in", 
		      user: {
			email: users(:david).email,
			password: 'password'
		      }
    assert_equal '/', path
    assert_equal I18n.t(:successful_sign_in), flash[:notice]    
  end
end
