environment 'production'

port	ENV['PORT']
threads ENV['MIN_THREADS'], ENV['MAX_THREADS']
workers ENV['WORKERS']

preload_app!

on_worker_boot do
	# Worker specific setup for Rails 4.1+
	# See: https://
	ActiveSupport.on_load(:active_record) do
		ActiveRecord::Base.establish_connection
	end
end