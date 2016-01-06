class API::EventsController < API::ApplicationController
  before_action :set_event,           only: [:show]
  #before_action :authenticate_user!
  before_action :teacher_user,        only: [:create]
  before_action :correct_user,        only: [:edit, :update]
  #before_action :admin_user,          only: :destroy
  respond_to :json

  #@@PAGE = 15

  def index
    #PAGE = EventsController.PAGE
    if params[:search]
      @search = Sunspot.search(Event) do
          #with(:user_id, params[:user].to_i)
          fulltext(params[:search])
           with(:event_start).greater_than(1.week.ago)
           with(:active, true)  
         facet(:event_month)
          with(:event_month, params[:month]) if params[:month].present?
          paginate(page: params[:page])
      end

      if params[:search]# || params[:user]
        @events = @search.results
      elsif params[:tag]
        @events = Event.tagged_with(params[:tag]).paginate(page: params[:page])
      else
        @events = @search.results
      end
    elsif params[:loc_id]
      @events = Event.where("loc_id" => params[:loc_id])
    # Handle user specific parameters  
    elsif params[:user_id]
      @events = Event.where("user_id" => params[:user_id]).order(event_start: :desc)
    # Handle school specific parameters
    elsif params[:school_id]
      @events = Event.where("school_id" => params[:school_id]).order(event_start: :desc)   
    end
    if params[:page]
      p = params[:page]
      @events = @events[p*PAGE..(p+1)*PAGE-1]
    else
      @events = @events[0..PAGE-1]
    end
    render json: {:events => list_events(@events)}.as_json
  end

  def pending_claims
    events = current_user.get_pending_claims()
    render json: {:events => list_events(filterDate(events))}.as_json
  end

  def pending_events
    events = Event.joins(:claims).where('events.user_id' => current_user.id)
                  .where('events.speaker_id'=> 0).where(active: true)
                  .where('claims.active' => true).where('claims.rejected' => false)
    render json: {:events => list_events(filterDate(events))}.as_json
  end

  def my_events
    events = Event.where("user_id = ? OR speaker_id = ?",  current_user.id, current_user.id).where(active: true)#speaker_id: current_user.id)
    render json: {:events => list_events(filterDate(events))}.as_json
  end    

  def confirmed
    id = current_user.id
    events = Event.where("user_id = ? OR speaker_id = ?", id, id).where.not(speaker_id: 0).where(active: true)
    render json: {:events => list_events(filterDate(events))}.as_json
  end

  def list_events(events)
    results = Array.new(events.count){Hash.new}
    for i in 0..events.count-1
      results[i] = {"id" => events[i].id, "event_title" => events[i].title, "event_start"=> events[i].start()}
    end
    return results
  end

  def filterDate(events)
    events.where("event_start > ?", Time.now)
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

  def update
    @event = Event.find(params[:id])
    params = event_params
    diff = false
    params.keys.each do |x|
      if @event[x] != params[x]
        diff = true
        break
      end
    end
    if diff

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
      @event.claims.create!(:user_id => current_user.id)
      render :json => {:state => 0, :event => @event }
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
