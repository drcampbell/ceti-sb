#log level defaults to :info
if Rails.env.production?
	Aws.config[:log_level] = :debug

	creds = Aws::Credentials.new(ENV["AWS_ACCESS_KEY"], ENV["AWS_SECRET_KEY"], ENV["AWS_REGION"])
	#mcreds = Aws::Credentials.new(ENV["SENDGRID_USERNAME"], ENV["SENDGRID_PASSWORD"])
	Aws.config[:credentials] = creds

	ActionMailer::Base.add_delivery_method :aws_sdk, Aws::SES::Client,
		credentials: creds,
		region: "us-west-2",
		endpoint: "email-smtp.us-west-2.amazonaws.com",
		raise_response_errors: true
		
	ActionMailer::Base.add_delivery_method :ses, Aws::SES::Client,
		access_key_id: ENV["AWS_ACCESS_KEY"],
		secret_access_key: ENV["AWS_SECRET_KEY"],
		credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY"], ENV["AWS_SECRET_KEY"]),
		region: "us-west-2",
		raise_response_errors: true,
		ssl_verify_peer: false
end
