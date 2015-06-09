module EventsHelper

	def get_events(params)
		if params.class == School
			@search = Sunspot.search(Event) do
				with :school_id, params.id
			end
			@events = @search.results
		elsif params.class == ActionController::Parameters
    	@search = Sunspot.search(Event) do
	      fulltext params[:search]
	       with(:event_start).less_than(Time.zone.now)
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
			with :school_id, school.id
		end
		@events = @search.results
	end

	def valid_event(event)
		event.user != nil && event.content != nil && event.title != nil
	end
end
