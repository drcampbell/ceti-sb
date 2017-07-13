class Notification < ActiveRecord::Base
	enum n_type: [:claim, :confirm_speaker, :event_update, :message, :award_badge, :new_badge, :cancel, :reject_claim, :cancel_claim, :cancel_speaker, :awarded_badge, :rejected_badge]
	belongs_to :user
	belongs_to :event
	after_create :send_gcm

	def content
		content = ""
		case n_type
		when "claim"
			content = "#{self.act_user_name} has claimed your event: #{Event.find(event_id).title}"
		when "confirm_speaker"
			content =  "#{self.act_user_name} has confirmed you as the speaker of event: #{Event.find(event_id).title}"
		when "event_update"
			content = "#{self.act_user_name} has updated event: #{Event.find(event_id).title}"
		when "message"
			content = "#{self.act_user_name} has sent you a message."
		when "award_badge"
			content = "Award #{self.act_user_name} a badge."
		when "new_badge"
			content = "#{self.act_user_name} awards you a badge!"
		when "cancel"
			content = "#{self.act_user_name} has canceled the event: #{Event.find(event_id).title}"
		when "reject_claim"
			content = "#{self.act_user_name} has chosen a different candidate for their event"
		when "cancel_claim"
			content = "#{self.act_user_name} has canceled their claim for event: #{Event.find(event_id).title}"
		when "cancel_speaker"
			content = "#{self.act_user_name} has to cancel their speaking engagement for event: #{Event.find(event_id).title}"
		when "awarded_badge"
      content = "You awarded #{self.act_user_name} a badge."
    when "rejected_badge"
      content = "You rejected #{self.act_user_name} a badge."
		end
		return content
	end

	def act_user_name
		if self.act_user_id > 0
			act_user_name = User.find(self.act_user_id).name
		else
			act_user_name = "Deleted User"
		end
	end

	def send_gcm()
	  puts "send_gcm"
		if !Rails.env.production?
			return
		end
		sns = Aws::SNS::Client.new(region: 'us-west-2')
		devices = Device.where(user_id: self.user_id)
		for device in devices
			# Skip the device if it isn't currently associated with an AWS endpoint_arn. 
			next if device.endpoint_arn == nil
			data = {message: self.content, n_type: n_type, event_id: event_id}
			data['count'] = Notification.where(user_id: self.user_id, read: false).count
			# For notifications regarding an event
			if self.event_id != 0
				event = Event.find(self.event_id)
				# Package information as this generates a fragment within Android
				if n_type == "award_badge"
					data['speaker_name'] = self.act_user_name
					data['event_name'] = Event.find(self.event_id).title
					data['badge_url'] = Badge.find(School.find(event.loc_id).badge_id).get_file_Name()
				# Package information as this generates a fragment within Android
				elsif n_type =="new_badge"
					data['user_name'] = User.find(self.user_id).name
					data['user_id'] = self.user_id
					data['event_owner'] = self.act_user_name
					data['event_owner_id'] = self.act_user_id
					data['event_name'] = event.title
					badge = UserBadge.where(user_id: self.user_id, event_id: event_id).last
					data['badge_url'] = Badge.find(badge.badge_id).get_file_Name()
					data['school_name'] = event.loc_name
					data['badge_id'] = badge.id
				end
			end
			begin # Publish to AWS SNS, note the dual to_json formatting. 
			  msg = {}
			  if device.device_type != nil
			  puts "Current device type = " + device.device_type
          
		    if(device.device_type == "ios")
		      puts "Executing ios"
		        apns_msg = "{\"aps\":{\"alert\":\"".concat(self.content) + "\"}, \"data\":" + data.to_json + "}"
			     msg = {APNS: apns_msg}.to_json
			  else
			    puts "Executing android"
          msg = {GCM: {data: data}.to_json}.to_json
			  end
			  end
			   puts msg
				sns.publish({
					target_arn: device.endpoint_arn,
					message_structure: "json",
					message: msg
					})
			# If the AWS endpoint is disabled, then don't send more notications to that device.  
			rescue Aws::SNS::Errors::EndpointDisabled, Aws::SNS::Errors::InvalidParameter
				device.update_attribute(:endpoint_arn, nil)
			end
		end
	end

	#Notification.create(user_id: 63,act_user_id: 34,event_id: 411,n_type: :event_update,read: false)

	def json_format
		result = self.attributes
    result[:user_name] = User.find(self.user_id).name
    result[:act_user_name] = self.act_user_name
    if self.event_id != 0
      result[:event_title] = Event.find(self.event_id).title
    end
		return result
	end

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
		when "cancel"
			link = "/events/#{event_id}"
		when "reject_claim"
			link = "/events/#{event_id}"	
		when "cancel_claim"
			link = "/events/#{event_id}"
		when "cancel_speaker"
			link = "/events/#{event_id}"
		end
		return link
	end

end
