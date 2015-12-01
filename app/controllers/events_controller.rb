class EventsController < ApplicationController
  before_action :set_event,           only: [:show]
  #before_action :authenticate_user!
  before_action :teacher_user,        only: [:create]
  before_action :correct_user,        only: [:edit, :update]
  before_action :admin_user,          only: :destroy

  class InvalidTime < StandardError
  end
  class MissingTime < StandardError
  end
  class MissingTitle < StandardError
  end

  rescue_from InvalidTime, :with => :invalid_time

  def index
    if not user_signed_in?
      redirect_to :signin
      return
    end

    # @search = Sunspot.search(Event) do
    #   fulltext params[:search]
    #    with(:start).less_than(Time.zone.now)
    #  facet(:event_month)
    #   with(:event_month, params[:month]) if params[:month].present?
    #   paginate(page: params[:page])

    # end
    # #debugger
    # if params[:search]
    #   @events = @search.results
    # elsif params[:tag]
    #   @events = Event.tagged_with(params[:tag]).paginate(page: params[:page])
    # else
    #   @events = @search.results
    # end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events.as_json }
    end
  end

#   def index
#     #fulltext params[:search]
#     #paginate(page: params[:page])
#     render text: params[:search]
#     #@search = Event.findby(params[:search])
#     #@search = Event.find(params[:search])
#     #@search = Sunspot.search(Event) do
# #      fulltext params[:search]
#       # with(:start).less_than(Time.zone.now)
# #      facet(:event_month)
# #      with(:event_month, params[:month]) if params[:month].present?
# #      paginate(page: params[:page])
#  #   end
#     if params[:search]
#  #     @events = @search.results
#     elsif params[:tag]
#       #@events = Event.tagged_with(params[:tag]).paginate(page: params[:page])
#     else
#  #     @events = @search.results
#     end
#     respond_to do |format|
#       format.html # index.html.erb
#       format.json { render json: @events.as_json }
#     end
#   end

  def show
    if user_signed_in?
      respond_to do |format|
        format.html do
          @event = Event.find(params[:id])
        end
        format.json do
          @event = Event.find(params[:id])
          render json: @event.as_json
        end
      end
    else
      redirect_to :signin
    end
  end

  def create
    begin
      if user_signed_in?
        params = event_params
        @event = current_user.events.build(params)
        validate_event(@event)
        adjust_time(@event)
        respond_to do |format|
          format.html do
            if @event.save
              flash[:success] = 'Event created!'
              redirect_to root_path
            else
              @feed_items = []
              flash.now[:notice] = "Event creation failed!\nPlease complete required fields."
              render :new  #'static_pages/home'
            end
          end
        end
      else
        redirect_to signin
      end
    rescue InvalidTime
      flash[:warning] = "You must enter a start time that preceeds the end time."
      render :new
    rescue ArgumentError
      flash[:warning] = "You must enter a start time that preceeds the end time."
      render :new
    rescue MissingTitle
      flash[:warning] = "You are missing a valid title"
      render :new
    rescue MissingTime
      flash[:warning] = "You are missing a valid start or end time"
      render :new
    end
  end

  def new
    if user_signed_in?
      if current_user.school_id > 1
        @event = current_user.events.build
      else
        redirect_to :choose
      end
    else
      redirect_to :signin
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    begin
      @event = Event.find(params[:id])
      params = event_params
      @event.attributes = params
      adjust_time(@event)
      validate_event(@event)
      diff = false
      params.keys.each do |x|
        if @event[x] != params[x]
          diff = true
          break
        end
      end
      if not diff
        redirect_to @event
      end
      success = @event.save
      if success and Rails.env.production?
        @event.update()
        # Claim.where(event_id: @event.id).each do |x|
        #   Notification.create(user_id: x.user_id,
        #                     act_user_id: @event.user_id,
        #                     event_id: @event.id,
        #                     n_type: :event_update,
        #                     read: false)
        # end
      end
    rescue InvalidTime
      flash[:warning] = "You must enter a start time that preceeds the end time."
      success = false
    rescue ArgumentError
      flash[:warning] = "You must enter a start time that preceeds the end time."
      success = false
    rescue MissingTitle
      flash[:warning] = "You are missing a valid title"
      success = false
    rescue MissingTime
      flash[:warning] = "You are missing a valid start or end time"
      success = false
    end

    respond_to do |format|
      if @event && success

        format.html do       
          flash[:success] = 'Event updated'
          redirect_to @event
        end
        format.json {render :json => {:state => {:code => 0}, status: :ok, :data => @event.to_json }}
        format.all { render_404 }
      elsif @event != nil
        format.html {render :edit, :alert => 'Unable to update event.'}
        format.json {render :json => {:state => {:code => 1, status: :error, :messages => @user.errors.full_messages} }}
        format.all {render_404}
      end
    end
  end

  def cancel
    @event = Event.find(params[:id])
    if current_user.id == @event.user_id
      @event.cancel(current_user.id)
      redirect_to root_url
    end
  end
  
  def destroy
    @event = Event.find params[:id]
    if current_user.id == @event.user_id
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
  end

  def claim_event
    # TODO Handle a speaker already being selected
    begin
      @event = Event.find(params[:event_id])
      @event.claim(params[:user_id])
      # @event.claims.create!(:user_id => params[:user_id])
      # if User.find(@event.user_id).set_claims
      #   UserMailer.event_claim(params[:user_id], @event.user_id, @event.id).deliver_now
      # end
      # Notification.create(user_id: @event.user_id,
      #                     act_user_id: params[:user_id],
      #                     event_id: @event.id,
      #                     n_type: :claim,
      #                     read: false)
      flash[:success] = "You have claimed event: #{@event.title}"
      redirect_to(root_url)
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Event not found"
      redirect_to(root_url)
    end
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:content, :title, :tag_list, :event_start, :event_end, :loc_id, :time_zone)
    end

    def validate_event(event)
      if not event.event_start? or not event.event_end?
        raise MissingTime
      elsif event.title == ""
        raise MissingTitle
      elsif event.event_start >= event.event_end
        raise InvalidTime
      end
    end

    def adjust_time(event)
      time_offset = Time.now.in_time_zone(event.time_zone).utc_offset
      event.event_start -= time_offset
      event.event_start = event.event_start.in_time_zone("UTC")
      event.event_end -= time_offset
      event.event_end = event.event_end.in_time_zone("UTC")
    end


  # Confirms the correct user.
  def correct_user
    @user = Event.find(params[:id]).user
    redirect_to(root_url) unless current_user == @user
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user && current_user.role == 'Admin'
  end
end
