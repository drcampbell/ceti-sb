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
   # @badge.fille_name = params[:file]
 
    if @badge.save
      puts "Searching for school Id #{badge_params[:school_id]}"
      school = School.find(badge_params[:school_id])
      school.badge_id = @badge.id
      school.save!
      uploader = MyUploader.new
      uploader.upload "badges/".concat(@badge.file.filename)
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