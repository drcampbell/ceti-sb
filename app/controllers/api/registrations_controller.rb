class API::RegistrationsController < Devise::RegistrationsController
respond_to :json
  def create
      #   build_resource(sign_up_params)
      #   resource_saved = resource.save
      #   yield resource if block_given?
      #   if resource_saved
      #     if resource.active_for_authentication?
      #       set_flash_message :notice, :signed_up if is_flashing_format?
      #       sign_up(resource_name, resource)
      #       respond_with resource, location: after_sign_up_path_for(resource)
      #     else
      #       set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
      #       expire_data_after_sign_in!
      #       respond_with resource, location: after_inactive_sign_up_path_for(resource)
      #     end
      #   else
      #     clean_up_passwords resource
      #     @validatable = devise_mapping.validatable?
      #     if @validatable
      #       @minimum_password_length = resource_class.password_length.min
      #     end
      #     respond_with resource
      #   end
      # end
      # format.json do
        @user = User.create(sign_up_params)
        if @user.save
          render :json => {:state => {:code => 0}, status: :ok, :data => @user }
        else
          render :json => {:state => {:code => 1, status: :error, :messages => @user.errors.full_messages} }
        end
    #   end
    # end
  end

  def profile
    if current_user.school_id == 1
      return redirect_to :choose
    end
    build_resource({})
    respond_with self.resource
    #return render "users/#{current_user.id}"
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :role, :email, :school_id, :grades, :biography, :job_title, :business, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name, :role, :email, :school_id, :grades, :biography, :job_title, :business, :password, :password_confirmation, :current_password, location_attributes: [:address])
  end
end