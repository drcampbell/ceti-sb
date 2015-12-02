class Claim < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  after_create :create_claim
  validates_uniqueness_of :user_id, scope: :event_id

  def create_claim
  	event = Event.find(self.event_id)
    UserMailer.event_claim(self.user_id, 
    											 event.user_id, 
    											 self.event_id).deliver_now
    Notification.create(user_id: event.user_id,
                        act_user_id: self.user_id,
                        event_id: event.id,
                        n_type: :claim,
                        read: false)
  end

  def teacher_confirm(event)
  	if self.update_attribute(:confirmed_by_teacher, true)
	  	event.update(speaker_id: self.user_id)
	  	if User.find(self.user_id).set_confirm
	      UserMailer.confirm_speaker(event.user_id, 
	      	                         self.user_id, 
	      	                         event.id).deliver_now
	    end
	  	Notification.create(user_id: self.user_id,
	                          act_user_id: event.user_id,
	                          event_id: event.id,
	                          n_type: :confirm_speaker,
	                          read: false)
	  	return true
	  else
	  	return false
  	end
  end

end
