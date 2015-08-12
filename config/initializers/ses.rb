module Aws
	module SES
		class Client
			def deliver!(mail)
				ses_return = send_email( source: Array(mail.from).first,
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