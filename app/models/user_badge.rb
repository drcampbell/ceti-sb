class UserBadge < ActiveRecord::Base
  belongs_to :user

  def get_badge_url()
  	b = Badge.find(self.badge_id)
  	b.get_badge_url()
  end
end
