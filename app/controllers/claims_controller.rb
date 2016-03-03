class ClaimsController < ApplicationController
  before_action :set_claim, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]

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
    # Note: claim event from the event controller is used instead
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

  def reject
    @claim = Claim.find(params[:id])
    @claim.reject()
    redirect_to root_url
  end

  def cancel
    @claim = Claim.find(params[:id])
    @claim.cancel()
    redirect_to root_url
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

  # Teacher confirms a speaker
  def teacher_confirm
    @event = Event.find(params[:event_id])
    @claim = Claim.find(params[:id])
    if @claim.teacher_confirm
      redirect_to(root_url)
      flash[:notice] = 'Claim was successfully confirmed.'
    else
      redirect_to(@claim.event)
      flash[:danger] = 'User '+@claim.user.name + " has cancelled their claim."
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
