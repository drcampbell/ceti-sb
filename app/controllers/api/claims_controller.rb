class API::ClaimsController < API::ApplicationController
  before_action :set_claim, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]

  respond_to :json

  def index
    respond_to do |format|
      format.html do
        @claims = Claim.all.paginate(page: params[:page])
      end
      format.json do
        @claims = Claim.all
        render json: @claims.as_json
      end
    end
  end

  def pending_claims
    #params = params.require(:event_id)
    if params[:event_id]
      event_id = params[:event_id]
    else
      #render_401 
    end
    claims = Claim.where(event_id: event_id)
    results = Array.new(claims.count){Hash.new}
    for i in 0..claims.count-1
      user = User.find(claims[i].user_id)
      results[i] = {"user_id" => user.id, "event_id"=>event_id, "user_name" => user.name, "business" => user.business, "job_title" => user.job_title, "school_id"  =>  user.school_id}
    end
    render json: {:claims => results}.as_json
  end

  def show
    respond_to do |format|
      format.html do
        @claim = Claim.find(params[:id])
      end
      format.json do
        @claim = Claim.find(params[:id])
        render json: @claim.as_json
      end
    end
  end

  def create
    @claim = Claim.new(params[:id])
    respond_to do |format|
      format.html do
        if @claim.save
          render 'static_pages/home'
          flash[:notice] = 'Claim was successfully created.'
        else
          render 'static_pages/home'
        end
      end
      format.json do
        if @claim.save
          render :json => {:state => {:code => 0}, :data => @claim.to_json }
        else
          render :json => {:state => {:code => 1, :messages => @claim.errors.full_messages} }
        end
      end
    end
  end



  def update
    flash[:notice] = 'Claim was successfully updated.'
    if @claim.update(claim_params)
      render @claim
    end
  end

  def destroy
    @claim.destroy
    respond_with(@claim)
  end

  def teacher_confirm
    @event = Event.find(params[:event_id])
    @claim = Claim.find(params[:id])
    if @claim.update_attribute(:confirmed_by_teacher, true)
      redirect_to(root_url)
      flash[:notice] = 'Claim was successfully confirmed.'
    end
  end

  def speaker_confirm
    @event = Event.find(params[:event_id])
    @claim = Claim.find(params[:id])
    if @claim.update_attribute(:confirmed_by_speaker, true)
      redirect_to(root_url)
      flash[:notice] = 'Event was successfully confirmed.'
    end
  end


  private
    def set_claim
      @claim = Claim.find(params[:id])
    end

    def claim_params
      params.require(:claim).permit(:event_id, :user_id)
    end

    # Confirms the correct user.
    def correct_user
      @user = Claim.find(params[:id]).user
      redirect_to(root_url) unless current_user == @user
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.role == 'Admin'
    end
end
