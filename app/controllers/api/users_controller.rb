class API::UsersController < API::ApplicationController

  #before_filter :authenticate_user!
  #before_action :correct_user,   only: [:update, :destroy]
  #before_action :admin_user,     only: :destroy
  respond_to :json

  def index
    pages = 15
    @search = Sunspot.search(User) do
      fulltext params[:search]
      paginate(page: params[:page])
    end
    if params[:search]e
      @users = @search.results
    elsif params[:tag]
      @users = User.tagged_with(params[:tag]).paginate(page: params[:page])
    else
      @users = User.all.paginate(page: params[:page])
    end

    # Only return one page of users (default=0 page)
    if params[:page]
      p = params[:page].to_i
      @users = @users[p*pages..(p+1)*pages-1]
    else
      @users = @users[0..pages-1]
    end

    if @users # Format the data for Android (Add fields with real names)     
      results = Array.new(@users.count) { Hash.new }
      for i in 0..results.count-1
        if @users[i].role == "Teacher" || @users[i].role == "Both"
          association = handle_abbr(School.find(@users[i].school_id).school_name)
        elsif @users[i].role == "Speaker"
          association == @users[i].business
        end
        results[i] = {"id" => @users[i].id, "name" => @users[i].name, "association" => association}
      end
      @users = results
    end

    render json: {:users => @users}.as_json
  end

  def show
    @user = User.find(params[:id])

    # if @user.school_id && @user.school_id != ""
    #   school_name =School.find(@user.school_id).school_name
    # else
    #   school_name = nil
    # end

    # user_message = {id: @user.id, name:@user.name, role:@user.role, 
    #                 grades:@user.grades, job_title:@user.job_title,
    #                 business:@user.business, biography:@user.biography,
    #                 category:@user.speaking_category, school_id:@user.school_id,
    #                 school_name:school_name}
    events = Event.where("user_id = ? or speaker_id = ?", @user.id, @user.id).order(event_start: :desc).take(20)
    badges = @user.user_badges
    badges_array = Array.new(badges.count){Hash.new}
    for i in 0..badges.count-1
      event = Event.find(badges[i].event_id)
      badges_array[i] = {"event_title" => event.title, 
                    "badge_id"=> badges[i].id, 
                    "badge_url" => Badge.find(badges[i].badge_id).file_name}
    end
    render json: { user: format_user(@user), events: list_events(events).as_json, badges: badges_array}

  end

  def format_user(user)
    if user.school_id && user.school_id != ""
      school_name =School.find(user.school_id).school_name
    else
      school_name = nil
    end
    user_message = {id: user.id, name:user.name, role:user.role, 
                    grades:user.grades, job_title:user.job_title,
                    business:user.business, biography:user.biography,
                    category:user.speaking_category, school_id:user.school_id,
                    school_name:school_name}
    return user_message
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)
    if @user.update_attributes(secure_params)
      render json: {state:0, user:format_user(@user)}
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

  def award_badge
    current_user.award_badge(params[:event_id], params[:award])
    render json: {state:0}
  end

  def show_badges
    user = User.find(:user_id)
    badges = User.user_badges
    results = Array.new(badges.count){Hash.new}
    for i in 0..badges.count-1
      event = Event.find(badges[i].event_id)
      results[i] = {"event_title" => event.title, 
                    "badge_id"=> badges[i].badge_id, 
                    "badge_url" => badges[i].file_name}
    end
    return results

  end

  def get_badge
    badge = UserBadge.find(params[:user_badge_id])
    event = Event.find(badge.event_id)
    render json: {
      user_id: params[:user_id],
      user_name: User.find(params[:user_id]).name,
      event_owner: User.find(event.user_id).name,
      event_owner_id: event.user_id,
      event_name: event.title,
      badge_url: Badge.find(badge.badge_id).file_name,
      school_name: event.loc_name,
      badge_id: badge.id}
  end

  def notifications
    pages = 15
    notifications = current_user.notifications()
    if params[:page]
      p = params[:page].to_i
      notifications = notifications[p*pages..(p+1)*pages-1]
    else
      notifications = notifications[0..pages-1]
    end
    render json: {notifications: notifications, count: current_user.unread_notifications()}
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
    render json: {notifications: current_user.notifications(), 
                    count: current_user.unread_notifications()}
  end

  def register_device
    device = Device.find_by(user_id: current_user.id, device_name: params[:device_name])
    if device != nil
      device.update(token: params[:token])
    else
      device = {user_id: current_user.id, device_name: params[:device_name], token: params[:token] }
      device = Device.create(device)
    end
    begin
      sns = Aws::SNS::Client.new(region: 'us-west-2')
      endpoint = sns.create_platform_endpoint(
        platform_application_arn: ENV["SNS_APP_ARN"],
        token: device.token)
      device.update(endpoint_arn: endpoint[:endpoint_arn])
    rescue
      puts json: {state: 1}
    end
    render json: {state: 0}
  end
  
  def list_events(events)
    results = Array.new(events.count){Hash.new}
    for i in 0..events.count-1
      results[i] = {"id" => events[i].id, "event_title" => events[i].title, "event_start"=> events[i].start()}
    end
    return results
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
