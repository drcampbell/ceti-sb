module EventsHelper

	def search()
		fulltext params[:search]
		paginate(page: params[:page])
		@search = Event.findby params[:search]
    #@search = Sunspot.search(Event) do
#      fulltext params[:search]
      # with(:start).less_than(Time.zone.now)
#      facet(:event_month)
#      with(:event_month, params[:month]) if params[:month].present?
#      paginate(page: params[:page])
 #   end
 		paginate(page: params[:page])
		if params[:tag]
			@events = Event.tagged_with(params[:tag]).paginate(page: params[:page])
		else
			@events = {}
		end
	end
end
