require "test_helper"

class API::UsersControllerTest < ActionController::TestCase
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

  def test_update
    u1 = users(:teacher); sign_in u1;
    put :update, id: u1.id, user: {grades: '9-12'}
    resp = JSON.parse(response.body)
    assert (resp["user"] == User.find(u1.id).json_format.as_json)
    sign_out u1
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

  def test_notifications
    u1 = users(:teacher)
    sign_in u1
    get :notifications, id: u1.id
    count = JSON.parse(response.body)['count']
    notif = notification_helper()
    get :notifications, id: u1.id
    resp = JSON.parse(response.body)
    assert (count + 1 == resp['count'])
    assert (resp['notifications'][0] != notif)
    notif.destroy
    sign_out u1
  end

  def test_read_notification
    u1 = users(:teacher)
    notif = notification_helper()
    sign_in u1
    assert_difference('u1.unread_notifications()', -1) do
      post :read_notification, id: notif.id
    end
    notif.destroy
    sign_out u1
  end

  def test_all_notifications_read
    u1 =  users(:teacher)
    notif = notification_helper()
    sign_in u1
    post :all_notifications_read, user_id: u1.id
    resp = JSON.parse(response.body)
    assert (resp['count'] == 0)
    notif.destroy
    sign_out u1
  end 

  def notification_helper
    u1 = users(:teacher)
    u2 = users(:speaker)
    Notification.create(user_id: u1.id, 
				act_user_id: u2.id, 
				event_id: events(:one).id,
				n_type: :claim,
				read: false)
  end

  #def test_destroy
    #user = User.create({name: 'Bob'})
    #assert_difference('User.count', -1) do
      #delete :destroy, id: user
    #end

    #assert_redirected_to users_path
  #end
end
