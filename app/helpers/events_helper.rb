module EventsHelper

	def get_events(params)
		if params.class == School
			@search = Sunspot.search(Event) do
				with :loc_id, params.id
			end
			@events = @search.results
		elsif params.class == ActionController::Parameters
    	@search = Sunspot.search(Event) do
	      fulltext params[:search]
	       with(:event_start).greater_than(1.week.ago)
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
    end
    return @events
	end

	def get_events2(school)
		@search = Sunspot.search(Event) do
			with :loc_id, school.id
		end
		@events = @search.results
	end

	def valid_event(event)
		event.user != nil && event.content != nil && event.title != nil
	end

	def present_time(event_start, event_end)
		s = event_start
		e = event_end
			return [s.strftime("%a"),s.strftime("%B"),(s.strftime("%d")).sub(/^0/, "")+",",s.strftime("%Y"),s.strftime("%l")+":"+s.strftime("%M"),
			"-",
		  e.strftime("%l")+":"+e.strftime("%M"),e.strftime("%p")].join(" ")
	end

	def get_all()
		return Event.where("user_id = ? OR speaker_id = ?",  current_user.id, current_user.id)
	end

	def get_approvals()
		return Event.joins(:claims).where('events.user_id' => current_user.id).where('events.speaker_id'=> nil)
	end

	def get_claims()
		return Event.joins(:claims).where('claims.user_id' => current_user.id)
	end
	
	def get_confirmed()
		id = current_user.id
    return Event.where("user_id = ? OR speaker_id = ?", id, id).where.not(:speaker_id => nil)    
	end


end
