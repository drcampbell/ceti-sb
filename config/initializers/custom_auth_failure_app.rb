class CustomAuthFailure < Devise::FailureApp
  # def respond
  #   self.status = 401
  #   self.content_type = 'json'
  #   self.response_body = {"errors" => ["Invalid login credentials"]}.to_json
  # end
  # def respond
  # 	if http_auth?
  # 		http_auth
  # 	elsif warden_options[:recall]
  # 		flash['danger'] = "Invalid Login Credentials"
  # 		recall
  # 	else
  # 		flash['danger'] = ["Invalid Login Credentials"]
  # 		redirect
  # 	end
	# end
	def recall
    config = Rails.application.config

    if config.try(:relative_url_root)
      base_path = Pathname.new(config.relative_url_root)
      full_path = Pathname.new(attempted_path)

      env["SCRIPT_NAME"] = config.relative_url_root
      env["PATH_INFO"] = '/' + full_path.relative_path_from(base_path).to_s
    else
      env["PATH_INFO"]  = attempted_path
    end

    flash.now['danger'] = i18n_message(:invalid) if is_flashing_format?
    self.response = recall_app(warden_options[:recall]).call(env)
  end

  # Check if flash messages should be emitted. Default is to do it on
  # navigational formats
  def is_flashing_format?
    is_navigational_format?
  end

    # self.status = 401
    # self.content_type = 'json'
    # self.response_body = {"errors" => ["Invalid login credentials"]}.to_json
  
end