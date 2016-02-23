class ApplicationController < ActionController::Base
  #before_filter :authenticate_user_from_token!
  #acts_as_token_authentication_handler_for User, 
    #unless: lambda { |StaticPagesController| }
  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_cache_headers

  include ActionController::MimeResponds
  include ActionController::StrongParameters
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session


  def hello
    render text: "hello cruel world"
  end
  
  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def must_signin
    render text: "You must be signed in to complete that action"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :role, :password, :password_confirmation, :current_password, :school, :grades, :job_title, :business) }
  end

  private
    # Confirms a teacher user.
    def teacher_user
      redirect_to(:signin) unless user_signed_in? && (current_user.role == 'Teacher' || current_user.role == 'Both')
    end

    # Confirms a speaker user.
    def speaker_user
      redirect_to(:signin) unless user_signed_in? && (current_user.role == 'Speaker' || current_user.role == 'Both')
    end

    def set_cache_headers
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    # def authenticate_user_from_token!
    #   user_email = params[:email].presence
    #   user = user_email && User.find_by_email(user_email)

    #   if user && Devise.secure_compare(user.authentication_token, params[:user_token])
    #     sign_in user, store: false
    #   end
    # end

end
