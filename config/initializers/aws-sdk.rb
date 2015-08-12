#log level defaults to :info
Aws.config[:log_level] = :debug

Aws.config[:credentials] = Aws::Credentials.new(ENV["AWS_ACCESS_KEY"], ENV["AWS_SECRET_KEY"])

ActionMailer::Base.add_delivery_method :ses, Aws::SES::Client,
	:access_key_id	=> ENV["AWS_ACCESS_KEY"],
	:secret_access_key => ENV["AWS_SECRET_KEY"]

