module Aws
	module SES
		class Client
			def deliver!(mail)
				if mail.from
					source = Array(mail.from).first
				else
					source = "schoolbusinessapp@gmail.com"
				end
				ses_return = send_email( source: source,
					destination: {
						to_addresses: mail.destinations
						},
						message: {
							subject: {
								data: mail.subject
							},
							body: {
								text: {
									data: mail.body.encoded
								},
								html: {
									data: mail.body.encoded
								}
							}
						})
				return ses_return.message_id
			end
		end
	end
end
