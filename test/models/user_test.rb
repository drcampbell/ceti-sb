require "test_helper"

class UserTest < ActiveSupport::TestCase

  def user
    @user ||= users(:teacher)
  end

  def test_valid
    User.all.each do |user|
      assert user.valid?
    end
  end

end
