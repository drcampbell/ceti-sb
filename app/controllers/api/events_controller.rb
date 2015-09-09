class API::EventsController < API::ApplicationController
  before_action :set_event,           only: [:show]
  #before_action :authenticate_user!
  before_action :teacher_user,        only: [:create]
  before_action :correct_user,        only: [:edit, :update]
  #before_action :admin_user,          only: :destroy
  respond_to :json

  def index
    if params[:search]
      @search = Sunspot.search(Event) do
          #with(:user_id, params[:user].to_i)
          fulltext(params[:search])
           with(:event_start).greater_than(1.week.ago)    
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
    end
    render json: {:events => list_events(@events)}.as_json
  end

  def pending_claims
    events = Event.joins(:claims).where('claims.user_id' => current_user.id)
    render json: {:events => list_events(events)}.as_json
  end

  def pending_events
    events = Event.joins(:claims).where('events.user_id' => current_user.id).where('events.speaker_id'=> nil)
    render json: {:events => list_events(events)}.as_json
  end

  def my_events
    events = Event.where("user_id = ? OR speaker_id = ?",  current_user.id, current_user.id)#speaker_id: current_user.id)
    render json: {:events => list_events(events)}.as_json
  end    

  def confirmed
    id = current_user.id
    events = Event.where("user_id = ? OR speaker_id = ?", id, id).where.not(speaker_id: nil)
    render json: {:events => list_events(events)}.as_json
  end

  def list_events(events)
    results = Array.new(events.count){Hash.new}
    for i in 0..events.count-1
      results[i] = {"id" => events[i].id, "event_title" => events[i].title, "event_start"=> events[i].event_start}
    end
    return results
  end

  def jsonEvent(event)
    school_name = nil
    user_name = nil
    if event.loc_id
      location_name = School.find(event.loc_id).school_name
    end
    if event.user_id
      user_name = User.find(event.user_id).name
    end
    result = event.attributes
    result[:user_name] = user_name
    result[:loc_name] = location_name
    if event.speaker_id and event.speaker_id != 0
      result[:speaker] = User.find(event.speaker_id).name
    else
      result[:speaker] = "TBA"
    end
    if Claim.exists?(event_id: event.id, user_id: current_user.id)
      result[:claim] = true
    else
      result[:claim] = false
    end
    return result
  end

  def show
    if user_signed_in?
      @event = Event.find(params[:id])
      result = jsonEvent(@event)   
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
    #params = event_params
    @event = Event.find(params[:id])
    params = event_params
    success = @event.update(params)

    if @event && success
      Claim.where(@event.id).each do |x|
        Notification.create(user_id: x.user_id,
                          act_user_id: @event.user_id,
                          event_id: @event.id,
                          n_type: :event_update,
                          read: false)
        if User.find(x.user_id).set_updates
          # TODO UserMailer.send_update().deliver
        end
      end
      render :json => {:state => 0, :event => jsonEvent(@event) }
    elsif @event != nil
      render :json => {:state => 1, :message => @user.errors.full_messages}
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
      @event = Event.find(params[:event_id])
      @event.claims.create!(:user_id => current_user.id)#params[:user_id])
      if User.find(@event.user_id).set_claims
        UserMailer.event_claim(params[:user_id], @event.user_id, @event.id).deliver_now
      end
      Notification.create(user_id: @event.user_id,
                          act_user_id: params[:user_id],
                          event_id: @event.id,
                          n_type: :claim,
                          read: false)

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
      permitted = params.require(:event).permit(:content, :title, :loc_id, :event_start, :event_end, :tags) #:tag_list,       
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
