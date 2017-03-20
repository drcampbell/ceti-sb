require 'csv'
class AdminController < ApplicationController
  before_action :admin_user
  def index
    if params != nil
      @header_array = []
      date_search
    end
    respond_to do |format|
        format.html # index.html.erb
        #format.json { render json: list_events(@events).as_json }
        format.csv do
          headers['Content-Disposition'] = "attachment; filename=\"Event-list\""
          headers['Content-Type'] ||= 'text/csv'
        end

    end
  end
  def date_search
    if params != nil && params[:fdate] != nil && params[:tdate] != nil
       
       if params[:format] != "csv" then
         fdate = params[:fdate] << " 12:00:00.0000"
         tdate = params[:tdate] << " 12:00:00.0000"
       
       else
         fdate = params[:fdate] 
         tdate = params[:tdate] 
       end
       
         
          
      if params[:commit] == "Summary View"
        puts "Summary View"
        @data = SearchService.new.date_search_db(fdate, tdate)
         @header_array << 'Schools Name'
         @header_array << 'Events Created' 
         @header_array << 'Events Claimed'
         @header_array << 'No of Awarded Badges'
       
        else if params[:commit] == "Detailed View"
        puts "Detailed View"
         @data = SearchService.new.detailed_view(fdate, tdate)
        
         
         @header_array << 'Start Date'
         @header_array << 'End Date' 
         @header_array << 'Schools Name'
         @header_array << 'Event Title'
         @header_array << 'Events Content'
         @header_array << 'Speaker'
         @header_array << 'Badge Awarded?'
         
        end
      end
    
    end
 end
 def admin_user
    redirect_to(root_url) unless current_user && current_user.role == 'Admin'
  end
 end
  
