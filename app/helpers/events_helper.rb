module EventsHelper

	def get_events(params)
		params[:per_page] = 30
		@events = SearchService.new.search(Event, params)
	end
# Old function for get_events...saving because i bastardized it
	#	def get_events(params)
#		if params.class == School
#			@search = Sunspot.search(Event) do
#				with :loc_id, params.id
#			end
#			@events = @search.results
#		elsif params.class == ActionController::Parameters
#    	@search = Sunspot.search(Event) do
#	      fulltext params[:search]
#	       with(:event_start).greater_than(Time.now)
#	       with(:active, true)
#	     facet(:event_month)
#	      with(:event_month, params[:month]) if params[:month].present?
#	      paginate(page: params[:page])
#	    end
#	    if params[:search]
#	      @events = @search.results
#	    elsif params[:tag]
#	      @events = Event.tagged_with(params[:tag]).paginate(page: params[:page])
#	    else
#	      @events = @search.results
#	    end
#    end
#    return @events
#    #return filterDate(events.where(active: true))
#	end

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
end
