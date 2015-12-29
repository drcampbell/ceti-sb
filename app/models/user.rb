class User < ActiveRecord::Base
  enum role: [:Admin, :Teacher, :Speaker, :Both]
  after_initialize :set_default_role, :if => :new_record?
  after_update :send_password_change_email, if: :needs_password_change_email?
  has_many :events, dependent: :destroy
  has_many :claims, dependent: :destroy
  has_many :user_badges
  has_many :devices
  belongs_to :school
  has_one :location, :through => :school
  has_one :location
  accepts_nested_attributes_for :location
  acts_as_taggable
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         :lockable

  searchable do
    text :name, :boost => 5
    text :job_title, :business, :school, :biography
  end

  def set_default_role
    self.role ||= :Both
    self.set_updates ||= true
    self.set_confirm ||= true
    self.set_claims  ||= true
  end

  def feed
    Event.where('user_id = ?', id).where(active: true)
  end

  def devices
    Device.where('user_id = ?', id)
  end

  def tag_list_commas
    self.tags.map(&:name).join(', ')
  end

  def get_badges

  end

  def get_pending_claims()
    events = Event.joins(:claims).where('claims.user_id' => self.id)
                  .where.not(speaker_id: self.id)
                  .where(active: true, complete: false)
                  .where('claims.cancelled' => false)
                  .where('claims.rejected' => false)
    return events
  end

  def send_message(to_id, message)
    begin
      UserMailer.send_message(self.id, to_id, message).deliver_now
      Notification.create(user_id: to_id,
                            act_user_id: self.id,
                            event_id: 0,
                            n_type: :message,
                            read: false)
      return true
    rescue
      return false
    end
  end

  def notifications()
    notifications = Notification.where(user_id: self.id)
    results = []
    notifications.each do |x|
      r = x.attributes
      r[:user_name] = User.find(x.user_id).name
      r[:act_user_name] = User.find(x.act_user_id).name
      if x.event_id != 0
        r[:event_title] = Event.find(x.event).title
      end
      results.append(r)
    end
    return results.reverse
  end

  def unread_notifications()
    return Notification.where(user_id: self.id, read: false).count
  end

  def award_badge(event_id, award)
    event = Event.find(event_id)
    if self.id == event.user_id
      if award
        badge_id = School.find(event.loc_id).badge_id
        UserBadge.create(user_id: event.speaker_id, 
                         badge_id: badge_id, 
                         event_id: event.id)
        Notification.create(user_id: event.speaker_id,
                            act_user_id: self.id,
                            event_id: event.id,
                            n_type: :new_badge,
                            read: false)
        event.update(complete: true)
      else
        event.update(complete: true)
      end
    end
  end

  def get_events()
    return Event.where("user_id = ? OR speaker_id = ?",  self.id, self.id)
                .where("event_start > ?", Time.now)
                .where(active: true)
  end

  private
  
    def needs_password_change_email?
      encrypted_password_changed? && persisted?
    end

    def send_password_change_email
      UserMailer.password_changed(id).deliver
    end

end