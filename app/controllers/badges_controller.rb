class BadgesController < ApplicationController
  respond_to :html
  def index
    @badges = Badge.all
  end
 
  def new
    @badge = Badge.new
  end
 
  def create
    puts "BadgeController(create):Uploading Badge"
    puts "BadgeController(create): Associated School id = #{@school.badge_id}"
    
    @badge.file = file
    @badge.save!
    @school.badge_id = @badge.id
    @school.save!
    
    uploader = BadgeUploader.new
    uploader.store!(file)
    
    
    @badge = Badge.new(badge_params)
 
    if @badge.save
      
      # badge = Badge.find(school.badge_id)
    # badge.file = file
    # badge.save!
    # uploader = BadgeUploader.new
    # uploader.store!(file)
      redirect_to badges_path, notice: "The badge #{@badge.name} has been uploaded."
    else
      render "new"
    end
  end
  
  def update
    puts "Updating badge!!"
    puts params
    @badge = Badge.new
    @badge.file = badge_params[:file]
    @badge.file_name = @badge.file.filename
     # new_file_name = badge_params[:school_id] 
    # puts "New File name: #{new_file_name}"
     # FileUtils.move("badges/#{@badge.file.filename}", new_file_name)
    # puts "File moved"
    # @badge.file.filename = new_file_name
   # @badge.fille_name = params[:file]
 
    if @badge.save
      puts "Searching for school Id #{badge_params[:school_id]}"
      school = School.find(badge_params[:school_id])
      aws = AWSServices.new
      
      #Deleting existing badge
      # if school.badge_id.present?
        # existing_badge = Badge.find(school.badge_id)
        # badge_folder_path = "badges/".concat(ENV["MODE"]).concat("/#{existing_badge.id}/")
        # if(existing_badge.file_name.present?)
          # badge_file_path = badge_folder_path + existing_badge.file_name
           
          # puts "Deleting AWS Object: " + badge_file_path
          # aws.delete badge_file_path
        # end
        # existing_badge.delete
      # end
      school.badge_id = @badge.id
      school.save!
      
      #uploader.upload "badges/".concat(badge_params[:school_id]).concat("/").concat(@badge.file.filename)
       badge_folder_path = "badges/".concat(ENV["MODE"]).concat("/#{@badge.id}/")
       badge_file_path = badge_folder_path + @badge.file.filename
      
      aws.upload badge_file_path
      FileUtils.rmtree  "public/" + badge_folder_path
      # badge = Badge.find(school.badge_id)
    # badge.file = file
    # badge.save!
    # uploader = BadgeUploader.new
    # uploader.store!(file)
      redirect_to :back, notice: "The badge #{@badge.name} has been uploaded."
    else
      render "new"
    end
  end
 
  def destroy
    @badge = Badge.find(params[:id])
    @badge.destroy
    redirect_to badges_path, notice:  "The badge #{@badge.name} has been deleted."
  end
 
private
  def badge_params
    params.require(:badge).permit(:name, :file, :school_id)
  end
end