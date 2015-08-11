#log level defaults to :info
Aws.config[:log_level] = :debug

Aws.config[:credentials] = Aws::Credentials.new(ENV["AWS_ACCESS_KEY"], ENV["AWS_SECRET_KEY"])

Aws.config[:mail_credentials] = Aws::Credentials.new(ENV["SENDGRID_USERNAME"], ENV["SENDGRID_PASSWORD"])