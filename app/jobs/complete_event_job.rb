class CompleteEventJob < ActiveJob::Base
  queue_as :default

  def perform()
  	#Notification.create(user_id: 34,act_user_id: 34, event_id: 0, n_type: :message, read:false)
  	#CompleteEventJob.set(queue: :default).perform_later()
     #puts Time.now
     #'2017-06-30 10:08:00 - 0400'
    events = Event.where('event_end < ?', Time.now).where(:complete => false)
    
    events.each do |x|
      claims = Claim.where(event_id: x.id).where(confirmed_by_teacher:true)
      
          notification = Notification.where(event_id: x.id, n_type: 4).first
          if notification != nil
            notification.send_gcm()
          else 
            
            claims.each do |i|
             
              userBadges = UserBadge.where(event_id: x.id).where(user_id:i.user_id).present?       
             
              if userBadges == false
                #puts "create"
           		  Notification.create(user_id: x.user_id,
                                   act_user_id: i.user_id,
                                   event_id: x.id,
                                   n_type: :award_badge,
                                   read: false)
              end
            end
          end 
    end
  end
end
