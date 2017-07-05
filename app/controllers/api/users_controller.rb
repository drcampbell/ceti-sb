class API::UsersController < API::ApplicationController #before_filter :authenticate_user!  #before_action :correct_user,   only: [:update, :destroy] #before_action :admin_user,     only: :destroy respond_to :json

  def index
    params[:per_page] = 15
    @users = SearchService.new.search(User, params)
    if @users # Format the data for Android (Add fields with real names)     
      @users = @users.map{ |user| user.json_list_format }
    end
    render json: {:users => @users}.as_json
  end

  def show
    @user = User.find(params[:id])
    # Get the users events TODO pass in all = true for Android 
    events = SearchService.new.search(Event, {user_id: @user.id, all: true})
    # Get the users badges and convert them to an appropriate format 
    badges = @user.user_badges.map{ |badge| badge.json_list_format }
    render json: { user: @user.json_format, 
                   events: events.map{|event| event.json_list_format}.as_json,
                   badges: badges}

  end


  def edit
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)
    if @user.update_attributes(secure_params)
      render json: {state:0, user:@user.json_format}
    else
      render json: {state:1}
    end
  end

  def destroy
    User.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        flash[:success] = 'User deleted'
        redirect_to users_path
      end
      format.json {render :json => {:state => {:code => 0, status: :ok} }}
    end
  end

  def send_message
    if current_user.send_message(params[:id], params[:user_message])
      render json: {state:0}
    else
      render json: {state:1}
    end
  end

  def get_award_badge
    event = Event.find(params[:event_id])
    badge = Badge.find(School.find(event.loc_id).badge_id)
    isAwarded = UserBadge.where(event_id: event.id, badge_id: badge.id).present?
    response = {badge_id: badge.id,
              badge_url: badge.get_file_Name(), 
             event_name: event.title,
             speaker_name:  User.find(event.speaker_id).name,
             event_id: event.id,
            isAwarded: isAwarded}
    render json: response.as_json
  end

  def post_award_badge
    current_user.award_badge(params[:event_id], params[:award])
    render json: {state:0}
  end

  def show_badges
    @user = User.find(:user_id)
    return @user.user_badges.map{|badge| badge.json_list_format}
  end

  def get_badge
    badge = UserBadge.find(params[:user_badge_id])
    render json: badge.json_format
  end
  
  def get_awarded_badge
    badge = UserBadge.where(user_id:params[:user_id], event_id:params[:event_id])
    render json: badge[0].json_format
  end

  def notifications
    pages = 15
    notifications = current_user.notifications().paginate(page: params[:page], per_page: pages)
    render json: {notifications: notifications.map{|n| n.json_format}, 
                  count: current_user.unread_notifications()}
  end

  def read_notification()
    if Notification.find(params[:id]).update(read: true)
      render json: {state: 0, count: current_user.unread_notifications()}
    else
      render json: {state: 1, count: 0}
    end
  end

  def all_notifications_read()
    notifications = Notification.where(user_id: current_user.id, read: false)
    notifications.each do |x|
      x.update(read: true)
    end
    render json: {
      notifications: current_user.notifications().paginate(page: 1).map{|n| n.json_format}, 
      count: current_user.unread_notifications()
    }
  end

  def register_device
    token = params[:token]
    
    otherDevices = Device.where(token: token).where.not(user_id: current_user.id)
    if(otherDevices != nil)
      otherDevices.each do |x|
        Device.delete(x.id)
      end
    end
    device = Device.find_by(user_id: current_user.id, device_name: params[:device_name])
    if device != nil
      device.update(token: params[:token])
    else
      device = Device.create({user_id: current_user.id, 
                              device_name: params[:device_name], 
                              token: params[:token],
                              device_type: params[:device_type] })
    end
    if(params[:device_type] == "ios")
      if device.register_ios_endpoint
        render json: {state: 0}
      else
        render json: {state: 1}
      end
    else
      if device.register_endpoint
        render json: {state: 0}
      else
        render json: {state: 1}
      end
    end
  end
  
  
  def unregister_device
    device = Device.find_by(user_id: current_user.id, 
      device_name: params[:device_name],
      token: params[:token],
      device_type: params[:device_type])    
    if device != nil
        if device.unregister_endpoint        
          device = Device.delete(device.id)
          render json: {state: 0}
        else
          render json: {state: 1}
        end
    else
      render json: {state: 1}
    end
  end
  
  private

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless @user.role == 'Admin'
  end

  def secure_params
    params.require(:user).permit(:id, :role, :name, :email, :biography, :school_id, :grades, :job_title, :business, :current_password, :tag_list, location_attributes: [:user_id, :address])
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user == @user
  end
end
