module SchoolsHelper

	def school_process(value, key)
        if value == nil
            return nil
        end
		states = {    AK: "Alaska", 
                AL: "Alabama", 
                AR: "Arkansas", 
                AS: "American Samoa", 
                AZ: "Arizona", 
                CA: "California", 
                CO: "Colorado", 
                CT: "Connecticut", 
                DC: "District of Columbia", 
                DE: "Delaware", 
                FL: "Florida", 
                GA: "Georgia", 
                GU: "Guam", 
                HI: "Hawaii", 
                IA: "Iowa", 
                ID: "Idaho", 
                IL: "Illinois", 
                IN: "Indiana", 
                KS: "Kansas", 
                KY: "Kentucky", 
                LA: "Louisiana", 
                MA: "Massachusetts", 
                MD: "Maryland", 
                ME: "Maine", 
                MI: "Michigan", 
                MN: "Minnesota", 
                MO: "Missouri", 
                MS: "Mississippi", 
                MT: "Montana", 
                NC: "North Carolina", 
                ND: "North Dakota", 
                NE: "Nebraska", 
                NH: "New Hampshire", 
                NJ: "New Jersey", 
                NM: "New Mexico", 
                NV: "Nevada", 
                NY: "New York", 
                OH: "Ohio", 
                OK: "Oklahoma", 
                OR: "Oregon", 
                PA: "Pennsylvania", 
                PR: "Puerto Rico", 
                RI: "Rhode Island", 
                SC: "South Carolina", 
                SD: "South Dakota", 
                TN: "Tennessee", 
                TX: "Texas", 
                UT: "Utah", 
                VA: "Virginia", 
                VI: "Virgin Islands", 
                VT: "Vermont", 
                WA: "Washington", 
                WI: "Wisconsin", 
                WV: "West Virginia", 
                WY: "Wyoming" 
        }.with_indifferent_access
		if key == 'phone' && value.length == 10
			"("+value[0..2]+") "+value[3..5]+"-"+value[6..9]
		elsif key == 'school_name' || key == 'loc_addr' || key == 'loc_city'
			handle_abbr(value)
		elsif key == 'loc_state'
			states[value]
		else
			value
		end
	end

	def handle_abbr(value)
            if value == nil
                return nil
            end
            value = value.titlecase
			abbr = {"Sch" => " School ", "Ln" => "Lane", "Elem" => "Elementary"}
			values = value.split(" ")
			newvalues =[]
			values.each do |v|
				if abbr[v] != nil
					newvalues += [abbr[v]]
				else
					newvalues += [v]
				end
			end
			newvalues.join(" ")
		end

  def get_events(id)
    @search = Sunspot.search(Event) do
      with(:school_id, id)
    end
    @events = @search.results
    # if params[:search]
    #   @events = @search.results
    # elsif params[:tag]
    #   @events = Event.tagged_with(params[:tag]).paginate(page: params[:page])
    # else
    #   @events = Event.all.paginate(page: params[:page])
    # end
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: @events.as_json }
    # end
  end

  def near_me
    @schools = School.near('Columbus, OH', 20)
    #@search = Sunspot.search(School) do
    #@schools = @search.results

  end
end
