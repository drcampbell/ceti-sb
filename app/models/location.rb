class Location < ActiveRecord::Base
  belongs_to :user, -> { where('role = ? OR role = ?', 0, 2) }
  belongs_to :school

  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

end
