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

  test "name should be present" do
    u1 = users(:test)
    u1.name = "     "
    assert u1.invalid?
  end

  test "email should be present" do 
    bad_emails = ['plainaddress',
		  '#@%^%#$@#$@#.com',
		  '@domain.com',
		  'Joe Smith <email@domain.com>',
		  'email.domain.com',
		  'email@domain@domain.com',
		  '.email@domain.com',
		  'email.@domain.com',
		  'email..email@domain.com',
		  'あいうえお@domain.com',
		  'email@domain.com (Joe Smith)',
		  'email@domain',
		  'email@-domain.com',
		  'email@domain.web',
		  'email@111.222.333.44444',
		  'email@domain..com']
    u1 = users(:test)
    bad_emails.each do |e|
      u1.email = e
      assert u1.invalid?
    end
  end

end
