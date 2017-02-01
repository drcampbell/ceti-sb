class Badge < ActiveRecord::Base
  mount_uploader :file, BadgeUploader
  belongs_to :school

  def get_badge_filename()
  	ENV["URL"] + ENV["S3_BUCKET"] + "/badges/"+ self.get_file_Name()
  end

  def json_list_format
    {"event_title" => Event.find(self.event_id).title,
     "badge_id" => self.id,
     "badge_url" => self.get_file_Name()
    }
  end
  def get_file_Name()
     if(self != nil && 
      self.file != nil && 
      self.file.file!= nil && 
      self.file.file.file != nil &&
      self.file.file.file.split("/")[-1] != nil)  
    
      return self.file.file.file.split("/")[-1]
    
    else
      return "def_school_badge_small.jpg"
    end
  end
  
end
