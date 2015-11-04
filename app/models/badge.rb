class Badge < ActiveRecord::Base
  mount_uploader :file, BadgeUploader
  belongs_to :school

  def get_badge_filename()
  	ENV["URL"] + ENV["S3_BUCKET"] + "/badges/"+ self.file_name
  end
end
