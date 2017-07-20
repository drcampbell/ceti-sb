class SchoolsController < ApplicationController
  before_action :set_school, only: [:show, :edit, :update]
  respond_to :html, :json
  # GET /schools
  # GET /schools.json
  def index
    respond_to do |format|
        format.html {  }
        #format.json { render json: {schools: @schools.map{|s| s.json_list_format}}.as_json }
         params[:per_page] = 15
          @schools = SearchService.new.search(School, params)
          respond_to do |format|
              format.html {if @schools.empty? then flash[:alert] = "No schools found" end}
              #format.json {@schools.map{|s| s.json_list_format}} 
           end
          #puts @school
    end
  end
 
  
  def near_me
    puts params[:zip].empty?
    if !params[:zip] ||  params[:zip].empty?
      index()
      return
    end
    zip = Zipcode.where(zip: params[:zip]).first
    if params[:radius] && !params[:radius].empty?
      radius = eval(params[:radius]) * 1609.34
    else
      radius = 10 * 1609.34
    end
    @schools = SearchService.new.location(zip.lat, zip.long, radius, params)
   respond_to do |format|
     format.html {if @schools.empty? then flash[:alert] = "No schools found" end}
    #format.json {@schools.map{|s| s.json_list_format}} 
   end
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
   
    @fields = {'school_name'  => 'Name', 
                  'loc_addr'  => 'Address', 
                  'loc_city'  => 'City', 
                  'loc_state' => 'State',
                  'loc_zip'   => 'Zip',
                  'phone'     => 'Phone'}
    @school = School.find(params[:id])     
    @badge = Badge.find(@school.badge_id)
    respond_to do |format|
      format.html do

      end
      #format.json { render json: @school.json_format}
    end
  end

  def choose

  end

  def claim_school
    @user = User.find(params[:user_id])
    @user.school_id = params[:school_id]
    @user.save
    redirect_to :profile
  end

  def make_mine
    @school = School.find params[:school_id]
    if user_signed_in?
      current_user.update(school_id: @school.id)
    end
    redirect_to :users
  end
  
  def upload_badge
    puts "Uploading badge"
    badge = Badge.find(@school.badge_id)
    badge.file = file
    badge.save!
    uploader = BadgeUploader.new
    uploader.store!(file)
  end
  
  # GET /schools/new
  def new
    @school = School.new
  end
  

  # GET /schools/1/edit
  def edit
  end

  # POST /schools
  # POST /schools.json
  def create
    @school = School.new(school_params)

    respond_to do |format|
      if @school.save
        format.html { redirect_to @school, notice: 'School was successfully created.' }
        #format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new }
        #format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schools/1
  # PATCH/PUT /schools/1.json
  def update
    @school = School.find params[:id]

    respond_to do |format|
      if @school && @school.update(school_params)
        format.html { redirect_to @school, notice: 'School was successfully updated.' }
        #format.json { render :show, status: :ok, location: @school }
        format.all { render_404 }
      elsif @school != nil
        format.html { render :edit }
        #format.json { render json: @school.errors, status: :unprocessable_entity }
        format.all { render_404 }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.json
  def destroy
    @school = School.find(params[:id])

    begin 
      @school.destroy!
    rescue
      puts "school not destroyed"
    end
      respond_to do |format|
        format.html { redirect_to schools_path, notice: 'School was successfully destroyed.' }
        #format.json { head :no_content }
      end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def school_params
      params[:school]
    end
end
