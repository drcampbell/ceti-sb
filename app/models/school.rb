class School < ActiveRecord::Base
  has_one :badge
  has_many :users, -> { where('role = ? OR role = ?', 1, 3) }
  has_one :location
  acts_as_taggable

  searchable do
  	text :school_name, :boost => 5
  	text :loc_addr
  	text :loc_city
  	text :loc_state
	end

end
