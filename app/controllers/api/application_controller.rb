class API::ApplicationController < ActionController::Base
  #before_filter :authenticate_user_from_token!
  acts_as_token_authentication_handler_for User
    #unless: lambda { |StaticPagesController| }
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  before_filter :authenticate_user!
  before_filter :configure_permitted_parameters, if: :devise_controller?

  include ActionController::MimeResponds
  include ActionController::StrongParameters
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  @@PAGE = 15
  
  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def must_signin
    render text: "You must be signed in to complete that action"
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.sanitize(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password, :school, :grades, :job_title, :business) }
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

    # def authenticate_user_from_token!
    #   user_email = params[:email].presence
    #   user = user_email && User.find_by_email(user_email)

    #   if user && Devise.secure_compare(user.authentication_token, params[:user_token])
    #     sign_in user, store: false
    #   end
    # end
  def handle_abbr(value)
            if value == nil
                return nil
            end
            value = value.titlecase
      abbr = {"Sch" => " School ", "Ln" => "Lane", "Elem" => "Elementary"}
      values = value.split(" ")
      newvalues =[]
      values.each do |v|
        if abbr[v] != nil
          newvalues += [abbr[v]]
        else
          newvalues += [v]
        end
      end
      newvalues.join(" ")
    end
end
