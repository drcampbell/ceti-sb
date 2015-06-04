require "test_helper"

class EventTest < ActiveSupport::TestCase

  def event
    @event ||= events(:one)
  end

  def test_valid
    assert event.valid?
  end

end
