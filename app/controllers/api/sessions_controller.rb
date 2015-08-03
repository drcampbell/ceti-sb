class API::SessionsController < Devise::SessionsController
# before_filter :ensure_params_exist
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  
  prepend_before_filter :require_no_authentication, only: [:new, :create]
  prepend_before_filter :allow_params_authentication!, only: :create
  prepend_before_filter only: [:create, :destroy] {request.env["devise.skip_timeout"] = true}
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  #skip_before_filter :authenticate_scope!, :only => [:update]

  acts_as_token_authentication_handler_for User

  respond_to :json

def create
  self.resource = warden.authenticate!(:scope => resource_name)
  sign_in(resource_name, resource)
  school_name = School.find(resource[:school_id]).school_name
  result = resource.attributes
  result[:school_name] = school_name
  render :json => result, :status => 200
end

def destroy
  puts "what FFFFFFF"
  respond_to do |format|
    format.json do
      puts "what FFFFFFF"
      if user.nil?
        render status: 404, json: { message: 'Invalid token.' }
      else
        user.update(:authentication_token => nil)
        user.save!
        render json: {status:0, message: "You have signed out."}
      end
    end
  end
end

  protected
    # def set_csrf_header
    #   response.headers['X-CSRF-Token'] = form_authenticity_token
    # end

    def ensure_params_exist
      return unless params[:user_login].blank?
      render :json=>{:success=>false, :message=> 'missing user_login parameter'}, :status=>422
    end

    def invalid_login_attempt
      warden.custom_failure!
      render :json=> {:success=>false, :message=> 'Error with your login or password'}, :status=>401
    end

    def sign_in_params
      devise_parameter_sanitizer.sanitize(:sign_in)
    end

    def serialize_options(resource)
      methods = resource_class.authentication_keys.dup
      methods = methods.keys if methods.is_a?(Hash)
      methods << :password if resource.respond_to?(:password)
      { methods: methods, only: [:password] }
    end
    
    def auth_options
      { scope: resource_name, recall: "#{controller_path}#new" }
    end


    private
    # Check if there is no signed in user before doing the sign out.
    #
    # If there is no signed in user, it will set the flash message and redirect
    # to the after_sign_out path.
      def verify_signed_out_user
        if all_signed_out?
          #set_flash_message :notice, :already_signed_out if is_flashing_format?
          #respond_to_on_destroy
        end
      end
      def all_signed_out?
        users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }
        users.all?(&:blank?)
      end
      def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
    end
  end
end