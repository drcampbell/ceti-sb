
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
      #puts("Value of search = " + params[:search])
      if params[:search] && params[:search] != ""
        puts "Searching within the resultset"
        query = handle_abbr(params[:search])
        # page = ""
        # if(params[:page] && params[:page] != "")
          # page = "LIMIT #{params[:page]}"
        # end
        # @schools = ActiveRecord::Base.connection.exec_query(
          # "select * 
          # from schools 
          # where id IN (#{ids.to_sentence})  
          # AND LOWER(school_name) like LOWER('%#{query}%')
          # ORDER BY school_name ASC #{page};"
        # )
#         
        # puts @schools
        @schools =  School.where(id: ids.to_a).search_full_text(query).paginate(page: params[:page], per_page: params[:per_page])
      else
        @schools =  School.where(id: ids.to_a).paginate(page: params[:page], per_page: params[:per_page])
      end

    else
      @schools =  School.where(id: 0).paginate(page: params[:page])
    end
    return @schools
  end

  def events_by_location(lat, long, radius, params)
    schools = ActiveRecord::Base.connection.exec_query(
      "SELECT * 
      FROM schools 
      WHERE earth_box(ll_to_earth(#{lat}, #{long}), #{radius}) 
      @> ll_to_earth(schools.latitude, schools.longitude);"
    )
    if schools.present?
      puts "Schools found"
      school_ids = schools.map{|s| s["id"]}
       
       if params[:search] && params[:search] != ""
        puts "Searching within the resultset"
        query = handle_abbr(params[:search])
        @event = Event.where(loc_id: school_ids).search_full_text(query).reorder(event_start: :desc)
                  .paginate(page: params[:page], per_page: params[:per_page])
       else
         @event = Event.where(loc_id: school_ids).reorder(event_start: :desc)
                  .paginate(page: params[:page], per_page: params[:per_page])
       end
    else  
      puts "no schools found"
      @event = Event.where(loc_id: 0).paginate(page: params[:page])
    end
    return @event
  end
  
  def date_search_db(fromdate, todate)
    
       #fromdate = '2016-05-05 07:37:49.228131'
       #todate = '2016-06-05 07:37:49.228131'
    #Events Created List
    events_created = ActiveRecord::Base.connection.exec_query("
    SELECT e.loc_id, count(e.*)FROM events as e WHERE (e.created_at BETWEEN '#{fromdate}'
     AND '#{todate}') GROUP BY loc_id ORDER BY loc_id;"     )

    if events_created.present?
      #Events Claimed List
      events_claim = ActiveRecord::Base.connection.exec_query("
      SELECT e.loc_id, count(e.*)FROM events as e WHERE id in (select c.event_id from claims as c 
          where (c.created_at BETWEEN '#{fromdate}'
           AND '#{todate}') ) AND(e.created_at BETWEEN '#{fromdate}'
           AND '#{todate}') GROUP BY loc_id ORDER BY loc_id;")
      
      #List events for which badges were awarded
      events_badges = ActiveRecord::Base.connection.exec_query("            
      SELECT e.loc_id, count(e.*)FROM events as e WHERE id in (select event_id from user_badges) AND 
      (e.created_at BETWEEN '#{fromdate}'
           AND '#{todate}') GROUP BY loc_id ORDER BY loc_id;")
          
    
        
       school_ids = events_created.map{|s| s["loc_id"]}
       schools =  School.select("id", "school_name").where(id: school_ids)
       schools = schools.map{ |u| [u.id, u] }.to_h
       
       @display_array = []
       claim_counter = 0
       badge_counter = 0
        events_created.each do |events_row|
         puts events_row['loc_id'] + " " + events_row['count']
         @row_array = []
         # key = events_row['loc_id']
        # puts schools[key].school_name
         #school_names = school_search.map{|s| s["id"]}
         school = schools[events_row['loc_id'].to_i]
         puts school.inspect
         @row_array << school.school_name
         @row_array << events_row['count']
       
         # events_claim.each do |claims_row|
         if events_claim.present?
          claims_row = events_claim[claim_counter]
          if  events_row['loc_id'] == claims_row['loc_id']
             @row_array << claims_row['count']
             claim_counter = claim_counter+1
           else
              @row_array << 0            
          end
                
           #events_badges.each do |badges_row|
           if events_badges.present?
             badges_row = events_badges[badge_counter]
              if  events_row['loc_id'] == badges_row['loc_id']
                 @row_array << badges_row['count']
                 badge_counter = badge_counter + 1
               else
                  @row_array << 0
              end
              else
                 @row_array << 0
               end
           else
             @row_array << 0
             @row_array << 0
          end
          
          
          @display_array <<  @row_array
          
        end
        return @display_array
        
      end
  end
  
  
  def detailed_view(fromdate, todate)
    
       #fromdate = '2016-05-05 07:37:49.228131'
       #todate = '2016-06-05 07:37:49.228131'
    #Events Created List
    events_created = ActiveRecord::Base.connection.exec_query("
      select e.title as title, e.content as content, e.event_start as event_start,
        e.event_end as event_end,s.school_name as school_name,
        u.name as name, b.event_id as badge_event_id     
      from events as e      
      LEFT JOIN schools as s ON s.id = e.loc_id
      LEFT JOIN users as u ON u.id = e.speaker_id
      LEFT JOIN user_badges as b ON b.event_id = e.id      
      where (event_start BETWEEN '#{fromdate}'
      AND '#{todate}')")

    if events_created.present?
      
       
       @display_array = []
       claim_counter = 0
       badge_counter = 0
        events_created.each do |events_row|
         @row_array = []
         @row_array << events_row['event_start']
         @row_array << events_row['event_end']
         @row_array << events_row['school_name'] 
         @row_array << events_row['title']
         @row_array << events_row['content']
         @row_array << events_row['name']
         
         if events_row['badge_event_id'].present?
           @row_array << 1
         else
           @row_array << 0
         end
               
          @display_array <<  @row_array
          
        end
        return @display_array
        
      end
  end
end
