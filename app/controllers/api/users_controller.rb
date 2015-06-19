class API::UsersController < API::ApplicationController

  #before_filter :authenticate_user!
  #before_action :correct_user,   only: [:update, :destroy]
  #before_action :admin_user,     only: :destroy
  respond_to :json

  def index
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
    for i in 0..@users.count-1
      results[i] = {"id" => @users[i].id, "name" => @users[i].name}
    end

    render json: @users.as_json

  end

  def show
    @user = User.find(params[:id])

    user_message = {id: @user.id, name:@user.name, role:@user.role, 
                    grades:@user.grades, job_title:@user.job_title,
                    business:@user.business, biography:@user.biography,
                    category:@user.speaking_category, school_id:@user.school_id,
                    school_name:School.find(@user.school_id).school_name}
    render json: user_message

  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      redirect_to @user, :alert => 'Unable to update user.'
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

  def message
  end
  
  private

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless @user.role == 'Admin'
  end

  def secure_params
    params.require(:user).permit(:id, :role, :name, :email, :school_id, :grades, :job_title, :business, :current_password, :tag_list, location_attributes: [:user_id, :address])
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user == @user
  end
end
