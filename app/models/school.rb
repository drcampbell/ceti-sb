class School < ActiveRecord::Base
  has_one :badge
  has_many :users, -> { where('role = ? OR role = ?', 1, 3) }
  has_one :location
end
