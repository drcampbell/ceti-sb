require "test_helper"

class ClaimTest < ActiveSupport::TestCase

  def test_valid
    claims.each do |claim|
      assert claim.valid?
    end
  end

  def test_reactivate
    claim = claims(:rejected)
    claim.reactivate()
    assert claim.active and !claim.rejected and !claim.cancelled
    claim = claims(:cancelled)
    claim.reactivate()
    assert !claim.active and !claim.rejected and claim.cancelled
  end

  def test_reject
    assert_difference('Notification.count', 1) do
      claim = claims(:active)
      claim.reject()
      assert claim.rejected and !claim.active
    end
  end

  def test_cancel
    assert_difference('Notification.count', 1) do 
      claim = claims(:active)
      claim.cancel()
      assert claim.cancelled and not claim.active
	#TODO Write test for speaker vs claimant Notification creatio
    end
  end

  def test_create_claim
  end 

  def test_teacher_confirm
    assert_difference('Notification.count', 1) do
      claim = claims(:active)
      claim.teacher_confirm
      assert claim.event.speaker_id == claim.user_id
      assert claim.confirmed_by_teacher 
    end    
  end
end
