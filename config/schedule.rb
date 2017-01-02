# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every_90_minutes = (24).times.map { |i| Date.today.to_time + (60) * i }

#every 1.hour, :at => every_90_minutes  do
every '*/5 * * * *' do
  #command "/usr/bin/some_great_command"
  #runner "CetiTasks.complete_events_task"
  rake "ceti_tasks:complete_events_task"
end

# every 1.day, :at => '3:30 am' do
	# rake "sunspot:solr:reindex"
# end

#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
