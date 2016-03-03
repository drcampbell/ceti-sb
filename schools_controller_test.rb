require "test_helper"

class SchoolsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    #@request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in :admin, @user
    sign_in @user
  end

  def school
    @school ||= schools :one
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:schools)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('School.count') do
      post :create, school: {school_name: "School For Ants"}
    end

    assert_redirected_to school_path(assigns(:school))
    sign_out :user
    sign_out @user
  end

  def test_show
    get :show, id: school
    assert_response :success
  end

  def test_edit
    get :edit, id: school
    assert_response :success
  end

  def test_update
    put :update, id: school, school: {  }
    assert_redirected_to school_path(assigns(:school))
  end

  def test_destroy
    #school = schools :one
    assert_difference('School.count', -1) do
      delete :destroy, id: school #params: { id: school.id }
    end

    assert_redirected_to schools_path
  end
end
