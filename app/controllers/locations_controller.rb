class LocationsController < ApplicationController
  #before_action :set_location, only: [:show, :edit, :update, :destroy]

  # GET /locations
  # GET /locations.json
  def index
    if params[:search].present?
      @locations = School.near(params[:search], 50).paginate(page: params[:page])
    else
      @locations = School.all.paginate(page: params[:page])
    end
    respond_to do |format|
      format.html {  }
      #format.json { render json: @locations.as_json }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @location = Location.find_by_id(params[:id])
  end

  # POST /locations
  # POST /locations.json
  def create
    respond_to do |format|
      @location = current_user.location.build(location_params)
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        #format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        #format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        #format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: 'Location was successfully destroyed.' }
      #format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @location = Location.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def location_params
    params.require(:claim).permit(:address, :latitude, :longitude, :user_id)
  end
end
