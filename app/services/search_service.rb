class SearchService
  def search(model, params)
    if params[:search]
      @search = model.search_full_text(params[:search])
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
end
