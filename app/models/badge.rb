class Badge < ActiveRecord::Base
  mount_uploader :file, BadgeUploader
  belongs_to :school

  def get_badge_filename()
  	ENV["URL"] + ENV["S3_BUCKET"] + "/badges/"+ self.file_name
  end

  def json_list_format
    {"event_title" => Event.find(self.event_id).title,
     "badge_id" => self.id,
     "badge_url" => self.file_name
    }
  end
end
