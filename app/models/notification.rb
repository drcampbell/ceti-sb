class Notification < ActiveRecord::Base
	enum n_type: [:claim, :confirm_speaker, :event_update]
	belongs_to :user

	def content
		content = ""
		case n_type
		when "claim"
			content = "#{User.find(act_user_id).name} has claimed your event: #{Event.find(event_id).title}"
		when "speaker_confirm"
			content =  "#{User.find(act_user_id).name} has confirmed you as the speaker of event: #{Event.find(event_id).title}"
		when "event_update"
			content = "#{User.find(act_user_id).name} has updated event: #{Event.find(event_id).title}"
		end
		return content
	end

	def link
		link = ""
		case n_type
		when "claim"
			link = "events/#{event_id}"
		when "speaker_confirm"
			link = "events/#{event_id}"
		when "event_update"
			link = "events/#{event_id}"
		end
		return link
	end

end