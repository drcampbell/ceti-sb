namespace :ceti_tasks do
  desc "TODO"
  task complete_events_task: :environment do
  	CompleteEventJob.set(queue: :default).perform_later()
  end

end
