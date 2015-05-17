class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?
  include ActionController::MimeResponds
  include ActionController::StrongParameters
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :school, :grades, :job_title, :business) }
  end

  private
  # Confirms a teacher user.
  def teacher_user
    redirect_to(root_url) unless current_user.role == 'Teacher' || current_user.role == 'Both'
  end

  # Confirms a speaker user.
  def speaker_user
    redirect_to(root_url) unless current_user.role == 'Speaker' || current_user.role == 'Both'
  end

end
