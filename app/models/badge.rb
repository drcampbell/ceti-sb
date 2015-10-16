class Badge < ActiveRecord::Base
  mount_uploader :file, BadgeUploader
  belongs_to :school

  def get_badge_url()
  	ENV["S3_URL"] + "badges/"+ this.url
  end
end
