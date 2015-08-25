require 'net/smtp'

module Net
	class SMTP
		def tls?
			if Rails.env.production?
				true
			else
				false
			end
		end
	end
end