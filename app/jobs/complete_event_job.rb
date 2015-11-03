class CompleteEventJob < ActiveJob::Base
  queue_as :default

  def perform()
  	#Notification.create(user_id: 34,act_user_id: 34, event_id: 0, n_type: :message, read:false)
  	#CompleteEventJob.set(queue: :default).perform_later()

    events = Event.where('event_end < ?', Time.now).where('speaker_id != ?',0).where(:complete => false)
    events.each do |x|
   		Notification.create(user_id: x.user_id,
                           act_user_id: x.speaker_id,
                           event_id: x.id,
                           n_type: :award_badge,
                           read: false)
    	end
  end
end
