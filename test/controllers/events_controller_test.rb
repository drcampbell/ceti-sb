require "test_helper"

class EventsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  

  def setup
    @test_users = [nil, :teacher, :speaker, :both, :admin]
  end

  def teardown
    @test_users = nil
  end

  def event
    @event ||= events :one
  end

  def test_index
    @test_users.each do |u|
      if u != nil
        sign_in :user, @user = users(u)
        sign_in @user
        get :index
        assert_response :success
        assert_not_nil assigns(:events)
        sign_out :user
        sign_out @user
      else 
        get :index
        assert_redirected_to :sign_in
      end
    end
  end

  def test_new
    @test_users.each do |u|
      if u 
        sign_in :user, users(u)
        get :new
        assert_response :success
        sign_out :user
      else
        get :new
        assert_redirected_to :signin
      end
    end
  end

  def test_create

    @test_users.each do |u|
      if u
        sign_in :user, @user = users(u)
        sign_in @user
        if @user.role == "Teacher" || @user.role == "Both"
          assert_difference('Event.count') do
            post :create, event: {  }
          end       
          assert_redirected_to event_path(assigns(:event))
        else
          assert_difference('Event.count', 0) do
            post :create, event: { }
          end
          assert_redirected_to :signin
        end
        sign_out :user
        sign_out @user
      else
        assert_difference('Event.count', 0) do
          post :create, event: { }
        end
        assert_redirected_to :signin
      end
    end
  end

  def test_show
    @test_users.each do |u|
      if u != nil
        sign_in :user, @user = users(u)
        sign_in @user
        get :index
        get :show, id: event
        assert_response :success
        sign_out :user
        sign_out @user
      else 
        get :show, id: event
        assert_redirected_to :signin
      end
    end    
  end

  def test_edit
    get :edit, id: event
    assert_response :success
  end

  def test_update
    assert_raises ActionController::ParameterMissing do
      put :update, id: event, event: { }
    end
    put :update, id: event, event: {:content => "hi"  }
    assert_redirected_to event_path(assigns(:event))
  end

  def test_destroy
    @test_users.each do |u|
      if u
        sign_in :user, @user = users(u)
        sign_in @user
        if @user.role == 0
          assert_difference('Event.count', 2) do
            delete :destroy, id: event
          end
          assert_redirected_to events_path
        else
          assert_difference('Event.count', 0) do
            delete :destroy, id: event
          end
        end
        sign_out :user
        sign_out @user
      else
        assert_difference('Event.count', 0) do
          delete :destroy, id: event
        end
      end
    end
  end

end
