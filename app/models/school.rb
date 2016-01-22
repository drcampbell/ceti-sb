class School < ActiveRecord::Base
  include PgSearch
  has_one :badge
  has_many :users, -> { where('role = ? OR role = ?', 1, 3) }
  has_many :events, dependent: :destroy
  acts_as_taggable

  #reverse_geocoded_by :latitude, :longitude, :address => :address
  #after_validation :reverse_geocode

  pg_search_scope :search_full_text, against: {
  	:school_name, 
  	:loc_addr,
  	:loc_city,
  	:loc_state,
  }

end
