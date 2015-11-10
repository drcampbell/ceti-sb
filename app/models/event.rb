class Event < ActiveRecord::Base
  extend SimpleCalendar
  belongs_to :user
  belongs_to :school
  has_calendar({:attribute => :event_start})
  has_many :claims, dependent: :destroy
  has_many :notifications, dependent: :destroy
  acts_as_taggable
  after_create :init
  validates_presence_of :title, :event_start, :event_end

  searchable do
    text :title, :boost => 5
    text :content, :event_month
    time :event_start
    string :event_month
    boolean :active
    integer :loc_id
    integer :user_id
    text :user_name
    text :loc_name
  end

  def init
    self.update_attribute(:speaker_id, 0)
    self.update_attribute(:user_name, User.find(self.user_id).name)
    self.update_attribute(:loc_name, School.find(self.loc_id).school_name)
    self.update_attribute(:active, true)
    self.update_attribute(:complete, false)
  end

  def tag_list_commas
    self.tags.map(&:name).join(', ')
  end

  def event_month
    self.event_start.strftime('%B %Y')
  end

  def get_pending_claims(user_id)
    filterDate(Event.joins(:claims).where('claims.user_id' => user_id).where.not(speaker_id: user_id).where(active: true))
  end

  def get_pending_events(user_id)
    filterDate(Event.joins(:claims).where('events.user_id' => user_id).where('events.speaker_id'=> 0).where(active: true))
  end

  def get_my_events(user_id)
    filterDate(Event.where("user_id = ? OR speaker_id = ?",  user_id, user_id).where(active: true))#speaker_id: current_user.id)
  end    

  def get_confirmed(user_id)
    filterDate(Event.where("user_id = ? OR speaker_id = ?", user_id, user_id).where.not(speaker_id: 0).where(active: true))
  end

  def filterDate(events)
    events.where("event_start > ?", Time.now)
  end

  def start()
    return self.event_start.in_time_zone(self.time_zone).strftime("%Y-%m-%d %H:%M %Z")
  end

  def end()
    self.event_end.in_time_zone(self.time_zone).strftime("%Y-%m-%d %H:%M %Z")
  end

  def date()
    self.event_end.in_time_zone(self.time_zone).strftime("%B %d, %Y")
  end

  def test()
    CompleteEventJob.set(queue: :default).perform_later()
  end
  
  def present_time()
    s = self.event_start.in_time_zone(self.time_zone)
    e = self.event_end.in_time_zone(self.time_zone)
      return [s.strftime("%a"),s.strftime("%B"),(s.strftime("%d")).sub(/^0/, "")+",",s.strftime("%Y"),s.strftime("%l")+":"+s.strftime("%M"),
      "-",
      e.strftime("%l")+":"+e.strftime("%M"),e.strftime("%p")].join(" ")
  end
end
