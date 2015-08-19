class BouncedEmailInterceptor

	def self.delivering_email(message)
		enum response_type: [ :bounce, :complaint, :ooto ]
		if (EmailResponse.exists?(email: message.to, response_type: :bounce) or EmailResponse.exists?(email: message.to, response_type: :complaint))
			message.perform_deliveries = false
			puts "Bounce should have happened"
		end
	end
end

ActionMailer::Base.register_interceptor(BouncedEmailInterceptor)