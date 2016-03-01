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
    claim = claims(:active)
    claim.reject()
    assert claim.rejected and !claim.active
  end

end
