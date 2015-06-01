class School < Location
  has_one :badge
  has_many :users, -> { where('role = ? OR role = ?', 1, 3) }
  has_many :events, dependent: :destroy
  acts_as_taggable
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

  searchable do
  	text :school_name, :boost => 5
  	text :loc_addr
  	text :loc_city
  	text :loc_state
	end

end
