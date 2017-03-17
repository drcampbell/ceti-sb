class AdminController < ApplicationController
  #before_action :admin_user
  def index
    if params != nil
      date_search
    end
    respond_to do |format|
        format.html # index.html.erb
        #format.json { render json: list_events(@events).as_json }
    end
  end
  def date_search
    if params != nil && params[:fdate] != nil && params[:tdate] != nil
       
       
       fdate = params[:fdate] << " 12:00:00.0000"
       tdate = params[:tdate] << " 12:00:00.0000"
      
      if params[:commit] == "Summary View"
        puts "Summary View"
        @data = SearchService.new.date_search_db(fdate, tdate)
       
        else if params[:commit] == "Detailed View"
        puts "Detailed View"
         @data = SearchService.new.detailed_view(fdate, tdate)
        end
      end
    
    end
 end
 end
  
