desc <<-END_DESC
Send issue reports via email.

Available options:
  * days     => number of days to remind about (defaults to 7)
  * tracker  => id of tracker (defaults to all trackers)
  * project  => id or identifier of project (defaults to all projects)
  * users    => comma separated list of user/group ids who should be notified
  * period   => mail subject: d=daily, w=weekly, m=monthly (defaults to none)
  * inactive_days => number of inactive days to report about (defaults to 7)

Example:
  rake redmine:send_issue_reports days=7 users="1,23,56" period=w RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_issue_reports => :environment do
    options = {}
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:project] = ENV['project'] if ENV['project']
    options[:tracker] = ENV['tracker'].to_i if ENV['tracker']
    options[:users] = (ENV['users'] || '').split(',').each(&:strip!)
    options[:period] = ENV['period'] if ENV['period']
    options[:inactive_days] = ENV['inactive_days'].to_i if ENV['inactive_days']

    Mailer.with_synched_deliveries do
      Mailer.issue_reports(options)
    end
  end
end
