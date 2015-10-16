class API::UsersController < API::ApplicationController

  #before_filter :authenticate_user!
  #before_action :correct_user,   only: [:update, :destroy]
  #before_action :admin_user,     only: :destroy
  respond_to :json

  def index
    puts params
    @search = Sunspot.search(User) do
      fulltext params[:search]
      paginate(page: params[:page])
    end
    if params[:search]
      @users = @search.results
    elsif params[:tag]
      @users = User.tagged_with(params[:tag]).paginate(page: params[:page])
    else
      @users = User.all.paginate(page: params[:page])
    end

    results = Array.new(@users.count) { Hash.new }
    for i in 0..results.count-1
      if @users[i].role == "Teacher" || @users[i].role == "Both"
        association = handle_abbr(School.find(@users[i].school_id).school_name)
      elsif @users[i].role == "Speaker"
        association == @users[i].business
      end
      results[i] = {"id" => @users[i].id, "name" => @users[i].name, "association" => association}
    end

    render json: {:users => results}.as_json

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
    b = @user.user_badges
    badges = []
    b.each do |x|
      badges.append(Badge.find(x.badge_id).file_name)
    end
    render json: { user: format_user(@user), events: list_events(events).as_json, badges: badges}

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
    begin 
      UserMailer.send_message(current_user.id, params[:id], params[:user_message]).deliver_now
      Notification.create(user_id: params[:id],
                            act_user_id: current_user.id,
                            event_id: 0,
                            n_type: :message,
                            read: false)
      render json: {state:0}
    rescue
      render json: {state:1}
    end
  end

  def notifications
    notifications = Notification.where(user_id: current_user.id)
    results = []
    notifications.each do |x|
      r = x.attributes
      r[:user_name] = User.find(x.user_id).name
      r[:act_user_name] = User.find(x.act_user_id).name
      r[:event_title] = Event.find(x.event_id).title
      results.append(r)
    end
    render json: {notifications: results.reverse}
  end

  def register_device
    device = Device.find_by(user_id: current_user.id, device_name: params[:device_name])
    if device != nil
      device.update(token: params[:token])
    else
      device = {user_id: current_user.id, device_name: params[:device_name], token: params[:token] }
      device = Device.create(device)
    end
    #render json: {state: 0}
    begin
      sns = Aws::SNS::Client.new(region: 'us-west-2')
      endpoint = sns.create_platform_endpoint(
        platform_application_arn: ENV["SNS_APP_ARN"],
        token: device.token
      )
      #)        attributes: { "user_id" => "#{device.user_id}"}
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
