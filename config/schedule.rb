# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every_90_minutes = (24 * 60).times.map { |i| Date.today.to_time + (60) * i }

every 1.day, at: every_90_minutes  do
  #command "/usr/bin/some_great_command"
  runner "CompleteEventJob.set(queue: :default).perform_later()"
  #rake "some:great:rake:task"
end

#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
