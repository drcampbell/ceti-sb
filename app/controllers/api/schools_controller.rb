class API::SchoolsController < API::ApplicationController
  before_action :set_school, only: [:show, :edit, :update]
  respond_to :json
  # GET /schools
  # GET /schools.json
  def index
    puts :controller 
    puts params
    @search = Sunspot.search(School) do
      fulltext params[:search]
      paginate(page: params[:page])
    end
    if params[:search]
      @schools = @search.results
    elsif params[:tag]
      @schools = School.tagged_with(params[:tag]).paginate(page: params[:page])
    else
      @schools = School.all.paginate(page: params[:page])
    end
    
    results = Array.new(@schools.count) { Hash.new }
    for i in 0..@schools.count-1
      city_state = @schools[i].loc_city+", "+@schools[i].loc_state
      results[i] = {"id" => @schools[i].id, "school_name" => @schools[i].school_name, "city_state" => city_state}
    end

    #@schools = @search.results#{:school_name => @schools
    #@schools = get_schools("") #School.first
    respond_to do |format|
        format.json { render json: {"schools"=> results}.as_json }
    end
  end
  
  # def near_me
  #   @schools = School.near('Columbus, OH', 20)
  #   #@search = Sunspot.search(School) do
  #   #@schools = @search.results

  # end

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
    school_message = {id: @school.id, name: @school.school_name,
                      address: @school.loc_addr, city: @school.loc_city,
                      state: @school.loc_state, zip: @school.loc_zip,
                      phone: @school.phone}
    render json: school_message

  end

  def choose

  end

  def claim_school
    #@school = School.find(params[:school_id])
    @user = User.find(params[:user_id])
    @user.school_id = params[:school_id]
    @user.save
    redirect_to :profile
  end

  def make_mine
    @school = School.find params[:id]
    if user_signed_in?
      current_user.school_id = @school.id
      render json: {state: 0, profile: current_user}
    else
      render json: {state: 1}
    end

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
        format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new }
        format.json { render json: @school.errors, status: :unprocessable_entity }
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
        format.json { render :show, status: :ok, location: @school }
        format.all { render_404 }
      elsif @school != nil
        format.html { render :edit }
        format.json { render json: @school.errors, status: :unprocessable_entity }
        format.all { render_404 }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.json
  def destroy
    @school = School.find params[:id]

    @school.destroy
      respond_to do |format|
        format.html { redirect_to schools_path, notice: 'School was successfully destroyed.' }
        format.json { head :no_content }
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
