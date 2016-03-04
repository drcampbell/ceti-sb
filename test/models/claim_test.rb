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
      claim = claims(:reject_me)
      claim.reject()
      assert claim.rejected and !claim.active
    end
  end

  def test_cancel
    assert_difference('Notification.count', 1) do 
      claim = claims(:cancel_me)
      # Make sure that the event is in the future to pass the time guard
      claim.event.update(event_start: Time.now + 3600)
      claim.event.update(event_end: Time.now + 3605)
      claim.cancel()
      assert claim.cancelled and not claim.active
	#TODO Write test for speaker vs claimant Notification creatio
    end
  end

  def test_create_claim
    assert_difference('Notification.count', 1) do
      claim = events(:claim_me).claims.create(user_id: users(:speaker).id)
      claim.save
      claim.destroy
    end
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
