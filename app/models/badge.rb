class Badge < ActiveRecord::Base
  mount_uploader :file, BadgeUploader
  belongs_to :school
  belongs_to :user
end
