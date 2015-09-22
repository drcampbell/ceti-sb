class Notification < ActiveRecord::Base
	enum n_type: [:claim, :confirm_speaker, :event_update, :message]
	belongs_to :user
	after_create :send_gcm

	def content
		content = ""
		case n_type
		when "claim"
			content = "#{User.find(act_user_id).name} has claimed your event: #{Event.find(event_id).title}"
		when "speaker_confirm"
			content =  "#{User.find(act_user_id).name} has confirmed you as the speaker of event: #{Event.find(event_id).title}"
		when "event_update"
			content = "#{User.find(act_user_id).name} has updated event: #{Event.find(event_id).title}"
		when "message"
			content = "#{User.find(act_user_id).name} has sent you a message."
		end
		return content
	end

	def send_gcm()
		sns = Aws::SNS::Client.new(region: 'us-west-2')
		devices = Device.where(user_id: self.user_id)
		for device in devices

			sns.publish({
				target_arn: device.endpoint_arn,
				message_structure: "json",
				message: {GCM: {data: {message: self.content}}.to_json}.to_json
				})
		end
	end

	def link
		link = ""
		case n_type
		when "claim"
			link = "/events/#{event_id}"
		when "speaker_confirm"
			link = "/events/#{event_id}"
		when "event_update"
			link = "/events/#{event_id}"
		when "message"
			link = "/users/#{act_user_id}"
		end
		return link
	end

end