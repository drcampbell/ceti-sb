require "test_helper"

class EventTest < ActiveSupport::TestCase

  def event
    @event ||= events(:one)
  end

  def test_valid
    Event.all.each do |event|
      if event.title and event.event_start and event.event_end and event.user_id
       	if event.title.length >= 2 and
	   event.title.length <= 256 and
	   event.user_id > 0
	  assert event.valid?
	else
	  assert event.invalid?
	end
      else
	assert event.invalid?
      end
    end
  end

end
