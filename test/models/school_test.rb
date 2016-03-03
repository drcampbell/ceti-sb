require "test_helper"

class SchoolTest < ActiveSupport::TestCase

  def school
    @school ||= schools(:one)
  end

  def test_valid
    School.all.each do |school|
      assert school.valid?
    end
  end

end
