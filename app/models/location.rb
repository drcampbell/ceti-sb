class Location < ActiveRecord::Base
  belongs_to :user, -> { where('role = ? OR role = ?', 0, 2) }
  belongs_to :school
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?
end
