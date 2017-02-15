class API::EventsController < API::ApplicationController
  before_action :set_event,           only: [:show]
  #before_action :authenticate_user!
  before_action :teacher_user,        only: [:create]
  before_action :correct_user,        only: [:edit, :update]
  #before_action :admin_user,          only: :destroy
  respond_to :json

  #@@PAGE = 15

  def index
    params[:per_page] = 15
    if params[:location] and params[:zip] != ""
      zip = Zipcode.where(zip: params[:zip]).first
      if params[:radius] != ""
        radius = eval(params[:radius]) * 1609.34
      else
        radius = 10 * 1609.34
      end
      @events = SearchService.new.events_by_location(zip.lat, zip.long, radius, params)
    else
      @events = SearchService.new.search(Event, params)
    end
    render json: {:events => list_events(@events)}.as_json
  end

  def pending_claims
    @events = current_user.get_pending_claims(params)
    render json: {:events => list_events(@events)}.as_json
  end

  def pending_events
    @events = current_user.get_event_approvals(params)
    render json: {:events => list_events(@events)}.as_json
  end

  def my_events
    @events = current_user.get_all_events(params)
    render json: {:events => list_events(@events)}.as_json
  end

  def confirmed
    @events = current_user.get_confirmed(params)
    render json: {:events => list_events(@events)}.as_json
  end

  def list_events(events)
    return events.map{|e| e.json_list_format}
  end

  def show
    if user_signed_in?
      @event = Event.find(params[:id])
      result = @event.jsonEvent(current_user.id)
      render json: result.as_json
    end
  end

  def create
    if user_signed_in?
      begin
        @event = current_user.events.build(event_params)        
        @event.save
        render :json => {:state => 0, :event => @event.to_json }
      rescue ActionController::ParameterMissing => e
          render :json => {:state => 1, :messages => "Parameter #{e.param} is required"}#@event.errors.full_messages }
      end
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

  def verifyChange(event, jsonEvent, key)
    case key
    when "event_start"
      return String(event.start()) != jsonEvent[key]
    when "event_end"
      return String(event.end()) != jsonEvent[key]
    else
      return String(event[key]) != jsonEvent[key]
    end
  end

  def update
    @event = Event.find(params[:id])
    params = event_params
    attrs  = @event.attributes
    @event.attributes = params
    updated = false
    if not params.map{|x,y| attrs[x] == @event[x]}.all?
      updated = true
      success = @event.update(params)
      if @event && success
        @event.handle_update()
        render :json => {:state => 0, :event => @event.jsonEvent(current_user.id) }
      elsif @event != nil
        render :json => {:state => 1, :message => @user.errors.full_messages}
      end
    else
      render :json => {:state => 0, :event => @event.jsonEvent(current_user.id)}
    end
  end

  def cancel
    @event = Event.find(params[:id])
    if current_user.id == @event.user_id
      @event.cancel(current_user.id)
      render :json => {:state => 1}
    end
  end

  def destroy
    if user_signed_in?
      puts params
      @event = Event.find params[:id]
      if User.find(@event.user_id).email == params[:user_email] #|| isAdmin(current_user)
        Event.destroy(params[:id])
        render :json => {:state => {:code => 0}}
      else
        render :json => {:state => {:code => 1, :message => "Not authorized to delete this event"} }
      end
    end
  end

  def claim_event
    # TODO Handle a speaker already being selected
    begin
      @event = Event.find(params[:id])
      @claim = Claim.where(event_id: @event.id, user_id: current_user.id)[0]
      if @claim and @claim.cancelled and not @claim.rejected
        @claim.update({active: true, cancelled: false})
        render :json => {:state => 0, :event => @event }
      elsif @claim and @claim.rejected
        render :json => {:state => 1, :message => "Your claim was rejected by the organizer"}
      else
        @event.claims.create!(:user_id => current_user.id)
        render :json => {:state => 0, :event => @event }
      end
    rescue ActiveRecord::RecordNotFound
      render :json => {:state => 1, :message => "Event not found" }
    end
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      permitted = params.require(:event).permit(:content, :title, :loc_id, :event_start, :event_end, :tags, :time_zone) #:tag_list,
      [:title, :event_start, :event_end].each do |x|
        if not permitted.has_key?(x) or permitted[x] == ""
          raise ActionController::ParameterMissing, x
        end
      end
      permitted
    end

  # Confirms the correct user.
  def correct_user
    @user = User.find(Event.find(params[:id]).user_id)
    redirect_to(root_url) unless current_user.id == @user.id
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user && current_user.role == 'Admin'
  end
end
