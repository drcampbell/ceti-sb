class CompleteEventJob < ActiveJob::Base
  queue_as :default

  def perform()
  	#Notification.create(user_id: 34,act_user_id: 34, event_id: 0, n_type: :message, read:false)
  	#CompleteEventJob.set(queue: :default).perform_later()
     #puts Time.now
     #'2017-06-30 10:08:00 - 0400'
    events = Event.where('event_end < ?', Time.now).where(:complete => false)
    user_list_map = Hash.new
    #puts "perform"
    events.each do |x|
      claims = Claim.where(event_id: x.id).where(confirmed_by_teacher:true)
      
          notification = Notification.where(event_id: x.id, n_type: 4).first
         
          if notification != nil
            #Send one push notification per run for a teacher 
            #puts "x.user_id" 
            if(user_list_map[x.user_id]  != 1)
              notification.send_gcm()
              #insert teacher if into hashmap
              user_list_map[x.user_id] = 1
              # puts "Adding #{x.user_id} to Hashmap"
            else
             # puts "Skipping #{x.user_id} - Push notification already sent"
            end
         
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
