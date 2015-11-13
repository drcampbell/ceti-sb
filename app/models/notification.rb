class Notification < ActiveRecord::Base
	enum n_type: [:claim, :confirm_speaker, :event_update, :message, :award_badge, :new_badge]
	belongs_to :user
	belongs_to :event
	after_create :send_gcm

	def content
		content = ""
		case n_type
		when "claim"
			content = "#{User.find(act_user_id).name} has claimed your event: #{Event.find(event_id).title}"
		when "confirm_speaker"
			content =  "#{User.find(act_user_id).name} has confirmed you as the speaker of event: #{Event.find(event_id).title}"
		when "event_update"
			content = "#{User.find(act_user_id).name} has updated event: #{Event.find(event_id).title}"
		when "message"
			content = "#{User.find(act_user_id).name} has sent you a message."
		when "award_badge"
			content = "Award #{User.find(act_user_id).name} a badge."
		when "new_badge"
			content = "#{User.find(act_user_id).name} awards you a badge!"
		end
		return content
	end

	def send_gcm()
		sns = Aws::SNS::Client.new(region: 'us-west-2')
		devices = Device.where(user_id: self.user_id)
		for device in devices
			next if device.endpoint_arn == nil
			event = Event.find(self.event_id)
			data = {message: self.content, n_type: n_type, event_id: event_id}
			if n_type == "award_badge"
				data['speaker_name'] = User.find(self.act_user_id).name
				data['event_name'] = Event.find(self.event_id).title
				data['badge_url'] = Badge.find(School.find(event.id).badge_id).file_name
			elsif n_type =="new_badge"
				data['user_name'] = User.find(self.user_id).name
				data['user_id'] = self.user_id
				data['event_owner'] = User.find(self.act_user_id).name
				data['event_owner_id'] = self.act_user_id
				data['event_name'] = event.title
				badge = UserBadge.where(user_id: self.user_id, event_id: event_id).last
				data['badge_url'] = Badge.find(badge.badge_id).file_name
				data['school_name'] = event.loc_name
				data['badge_id'] = badge.id
			end
			begin
				sns.publish({
					target_arn: device.endpoint_arn,
					message_structure: "json",
					message: {GCM: {data: data}.to_json}.to_json
					})
			rescue Aws::SNS::Errors::EndpointDisabled
				device.update_attribute(:endpoint_arn, nil)
			end
		end
	end

	#Notification.create(user_id: 63,act_user_id: 34,event_id: 411,n_type: :event_update,read: false)


	def link
		link = ""
		case n_type
		when "claim"
			link = "/events/#{event_id}"
		when "confirm_speaker"
			link = "/events/#{event_id}"
		when "event_update"
			link = "/events/#{event_id}"
		when "message"
			link = "/users/#{act_user_id}"
		when "award_badge"
			link = "/events/#{event_id}"
		when "new_badge"
			link = "/events/#{event_id}"
		end
		return link
	end

end