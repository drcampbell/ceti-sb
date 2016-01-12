class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def home
    if user_signed_in?
      @event  = current_user.events.build
      @feed_items = current_user.feed.paginate(page: params[:page]).order('created_at DESC')
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def signin
  end

  def getting_started
  end
end
