class UserBadge < ActiveRecord::Base
  belongs_to :user
  after_create :notify

  def notify()
  	event = Event.find(self.event_id)
  	Notification.create(user_id: self.user_id,
  											act_user_id: event.user_id,
  											event_id: event.id,
  											n_type: :new_badge,
  											read: false)
  end

  def get_badge_filename()
  	b = Badge.find(self.badge_id)
  	b.get_badge_filename()
  end
end
