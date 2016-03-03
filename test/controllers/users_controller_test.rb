require "test_helper"

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users
  #def user
    #@user ||= users :teacher
  #end

  def test_index
    sign_in users(:both)
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  # def test_new
  #   get :new
  #   assert_response :success
  # end

  # def test_create
  #   assert_difference('User.count') do
  #     post :create, user: {  }
  #   end

  #   assert_redirected_to user_path(assigns(:user))
  # end

  def test_show
    User.all.each do |user|
      sign_in user
      get :show, id: users(:teacher).id
      assert_response :success
    end
  end


  # def test_update
  #   put :update, id: user, user: {  }
  #   assert_redirected_to user_path(assigns(:user))
  # end

  #def test_destroy
    #user = User.create({name: 'Bob'})
    #assert_difference('User.count', -1) do
      #delete :destroy, id: user
    #end

    #assert_redirected_to users_path
  #end
end
