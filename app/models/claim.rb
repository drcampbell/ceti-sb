class Claim < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  after_create :create_claim
  validates_uniqueness_of :user_id, scope: :event_id

  def create_claim
    event = Event.find(self.event_id)
    if Rails.env.production?
      if User.find(event.user_id).set_claims
          UserMailer.event_claim(self.user_id, 
                                                                                           event.user_id, 
                                                                                           self.event_id).deliver_now
      end
      Notification.create(user_id: event.user_id,
                          act_user_id: self.user_id,
                          event_id: event.id,
                          n_type: :claim,
                          read: false)
    end
  end

  def reject()
    self.update(:rejected => true)
    self.update(:active => false)
    event = Event.find(self.event_id)
    if Rails.env.production?
      UserMailer.reject_claim(self.user_id,
                              event.user_id,
                              self.event_id).deliver_now
      Notification.create(user_id:self.user_id,
                          act_user_id: event.user_id,
                          event_id: event.id,
                          n_type: :reject_claim,
                          read: false)
    end
  end

  def reactivate()
    claims = Claim.where(event_id: self.event_id)
    claims.each do |x|
      if not x.cancelled
        x.update(active: true)
        x.update(rejected: false)
      end
    end
  end

  def cancel()
    self.update(active: false)
    self.update(cancelled: true)
    event = Event.find(self.event_id)
    if event.speaker_id == self.user_id
      event.update(speaker_id: 0)
      if Rails.env.production?
        UserMailer.cancel_speaker(self.user_id,
                              event.user_id,
                              self.event_id).deliver_now
        Notification.create(user_id: event.user_id,
                      act_user_id: self.user_id,
                      event_id: event.id,
                      n_type: :cancel_speaker,
                      read: false)
      end
      self.reactivate()
    else     
      if Rails.env.production?
        UserMailer.cancel_claim(self.user_id,
                                event.user_id,
                                self.event_id).deliver_now
        Notification.create(user_id:event.user_id,
                        act_user_id: self.user_id,
                        event_id: event.id,
                        n_type: :cancel_claim,
                        read: false)     
      end
    end
  end

  def json_list_format
      user = User.find(self.user_id)
      {
        "user_id" => user.id, 
        "event_id"=> self.id,
        "user_name" => user.name,
        "business" => user.business, 
        "job_title" => user.job_title, 
        "school_id"  =>  user.school_id, 
        "claim_id"=> self.id
      }
  end

  def teacher_confirm(event)
  	if self.update_attribute(:confirmed_by_teacher, true)
	  	event.update(speaker_id: self.user_id)
      if Rails.env.production?
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
      end
	  	return true
	  else
	  	return false
  	end
  end

end
