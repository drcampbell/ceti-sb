#log level defaults to :info
Aws.config[:log_level] = :debug

creds = Aws::Credentials.new(ENV["AWS_ACCESS_KEY"], ENV["AWS_SECRET_KEY"])
mcreds = Aws::Credentials.new(ENV["SENDGRID_USERNAME"], ENV["SENDGRID_PASSWORD"])
Aws.config[:credentials] = creds

ActionMailer::Base.add_delivery_method :aws_sdk, Aws::SES::Client,
	credentials: creds,
	region: "us-west-2"
	
ActionMailer::Base.add_delivery_method :ses, Aws::SES::Client,
	:access_key_id	=> ENV["SENDGRID_USERNAME"],
	:secret_access_key => ENV["SENDGRID_PASSWORD"]

