class EventsController < ApplicationController
  before_action :set_event,           only: [:show]
  #before_action :authenticate_user!
  before_action :teacher_user,        only: [:create]
  before_action :correct_user,        only: [:edit, :update]
  before_action :admin_user,          only: :destroy

  def index
    @search = Sunspot.search(Event) do
      fulltext params[:search]
      # with(:start).less_than(Time.zone.now)
      facet(:event_month)
      with(:event_month, params[:month]) if params[:month].present?
      paginate(page: params[:page])
    end
    if params[:search]
      @events = @search.results
    elsif params[:tag]
      @events = Event.tagged_with(params[:tag]).paginate(page: params[:page])
    else
      @events = @search.results
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events.as_json }
    end
  end

  def show
    respond_to do |format|
      format.html do
        @event = Event.find(params[:id])
      end
      format.json do
        @event = Event.find(params[:id])
        render json: @event.as_json
      end
    end
  end

  def create
    @event = current_user.events.build(event_params)
    respond_to do |format|
      format.html do
        if @event.save
          flash[:success] = 'Event created!'
          redirect_to root_path
        else
          @feed_items = []
          flash[:notice] = 'Event creation failed!'
          render 'static_pages/home'
        end
      end
      format.json do
        if @event.save
          render :json => {:state => {:code => 0}, :data => @event.to_json }
        else
          @feed_items = []
          render :json => {:state => {:code => 1, :messages => @event.errors.full_messages} }
        end
      end
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    respond_to do |format|
      format.html do
        @event = Event.find(params[:id])
        if @event.update_attributes(event_params)
          flash[:success] = 'Event updated'
          redirect_to root_path
        else
          render :edit, :alert => 'Unable to update event.'
        end
      end
      format.json do
        @event = Event.find(params[:id])
        if @event.update_attributes(event_params)
          render :json => {:state => {:code => 0}, status: :ok, :data => @event.to_json }
        else
          render :json => {:state => {:code => 1, status: :error, :messages => @user.errors.full_messages} }
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      format.html do
        @event.destroy
      end
      format.json do
        if @event.destroy
          render :json => {:state => {:code => 0}}
        else
          render :json => {:state => {:code => 1, :messages => @user.errors.full_messages} }
        end
      end
    end
  end

  def claim_event
    @event = Event.find(params[:event_id])
    @event.claims.create!(:user_id => params[:user_id])
    redirect_to(root_url)
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:content, :title, :tag_list, :start, :end)
    end

  # Confirms the correct user.
  def correct_user
    @user = Event.find(params[:id]).user
    redirect_to(root_url) unless current_user == @user
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.role == 'Admin'
  end
end
