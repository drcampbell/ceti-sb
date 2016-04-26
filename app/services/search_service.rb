class SearchService
 
  def handle_abbr(query) 
  state_to_abbr = {"Alaska"=>"AK", "Alabama"=>"AL", "Arkansas"=>"AR", "American Samoa"=>"AS", "Arizona"=>"AZ", "California"=>"CA", "Colorado"=>"CO", "Connecticut"=>"CT", "District of Columbia"=>"DC", "Delaware"=>"DE", "Florida"=>"FL", "Georgia"=>"GA", "Guam"=>"GU", "Hawaii"=>"HI", "Iowa"=>"IA", "Idaho"=>"ID", "Illinois"=>"IL", "Indiana"=>"IN", "Kansas"=>"KS", "Kentucky"=>"KY", "Louisiana"=>"LA", "Massachusetts"=>"MA", "Maryland"=>"MD", "Maine"=>"ME", "Michigan"=>"MI", "Minnesota"=>"MN", "Missouri"=>"MO", "Mississippi"=>"MS", "Montana"=>"MT", "North Carolina"=>"NC", "North Dakota"=>"ND", "Nebraska"=>"NE", "New Hampshire"=>"NH", "New Jersey"=>"NJ", "New Mexico"=>"NM", "Nevada"=>"NV", "New York"=>"NY", "Ohio"=>"OH", "Oklahoma"=>"OK", "Oregon"=>"OR", "Pennsylvania"=>"PA", "Puerto Rico"=>"PR", "Rhode Island"=>"RI", "South Carolina"=>"SC", "South Dakota"=>"SD", "Tennessee"=>"TN", "Texas"=>"TX", "Utah"=>"UT", "Virginia"=>"VA", "Virgin Islands"=>"VI", "Vermont"=>"VT", "Washington"=>"WA", "Wisconsin"=>"WI", "West Virginia"=>"WV", "Wyoming"=>"WY"} 
    #state_to_abbr.keys.each do |st|
      #if query.downcase.include? st.downcase
        #query += " " + state_to_abbr[st]
      #end
    #end
    state_to_abbr.keys.each do |st|
      if query.include? st
        query[st] = state_to_abbr[st]
      end
    end
    return query
  end

  def search(model, params)

    if params[:search]
      query = handle_abbr(params[:search])
      @search = model.search_full_text(query)
      if model == Event
        @search = @search.reorder(event_start: :desc)
      end
    # Search model records tagged with a tag
    elsif params[:tag]
      @search = model.tagged_with(params[:tag])
    # Search model by location id
    elsif model == Event and params[:loc_id]
      @search = model.where("loc_id" => params[:loc_id])
    # Search model by user id
    elsif model == Event and params[:user_id]
      if params[:all]
        @search = model.where("user_id = ? or speaker_id = ?", params[:user_id], params[:user_id]).reorder(event_start: :desc)
      else
        @search = model.where("user_id" => params[:user_id]).reorder(event_start: :desc)
      end
    # Search model by school id
    elsif model == Event and params[:school_id]
      @search = model.where("loc_id" => params[:school_id]).reorder(event_start: :desc)
    # If nothing else matches just return all of them!
    else
      if model == Event
        @search = model.all.reorder(event_start: :desc)
      else
        @search = model.all
        if model == School
          @search = @search.reorder(school_name: :asc)
        end
      end
    end
    @search.paginate(page: params[:page], per_page: params[:per_page])
  end

  def location(lat, long, radius, params)
      #"SELECT * FROM schools WHERE earth_box(ll_to_earth(34.263197, -86.205836), 1000) @> ll_to_earth(schools.latitude, schools.longitude);"
    results = ActiveRecord::Base.connection.exec_query(
      "SELECT * 
      FROM schools 
      WHERE earth_box(ll_to_earth(#{lat}, #{long}), #{radius}) 
      @> ll_to_earth(schools.latitude, schools.longitude);"
    )
    if results.present?
      ids = results.map{|r| r['id']}
      return School.where(id: ids.to_a).paginate(page: params[:page], per_page: params[:per_page])
    else
      return School.where(id: 0).paginate(page: params[:page])
    end
  end

  def events_by_location(lat, long, radius, params)
    schools = ActiveRecord::Base.connection.exec_query(
      "SELECT * 
      FROM schools 
      WHERE earth_box(ll_to_earth(#{lat}, #{long}), #{radius}) 
      @> ll_to_earth(schools.latitude, schools.longitude);"
    )
    if schools.present?
      school_ids = schools.map{|s| s["id"]}
      return Event.where(loc_id: school_ids).reorder(event_start: :desc)
                  .paginate(page: params[:page], per_page: params[:per_page])
    else
      return Event.where(loc_id: 0).paginate(page: params[:page])
    end
  end

end
