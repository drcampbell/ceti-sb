class CompleteEventJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    Event.where('event_end < ?', Time.now).where('speaker_id != ?',0).where(:complete => true)
  end
end
