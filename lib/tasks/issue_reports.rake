desc <<-END_DESC
Send issue reports via email.

Available options:
  * days     => number of days to remind about (defaults to 7)
  * tracker  => id of tracker (defaults to all trackers)
  * project  => id or identifier of project (defaults to all projects)
  * users    => comma separated list of user/group ids who should be notified

Example:
  rake redmine:send_issue_reports days=7 users="1,23,56" RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_issue_reports => :environment do
    # Load monkey patches properly
    RedmineApp::Application.eager_load!
    require File.join(Rails.root, "plugins/redmine_issue_reports/app/models/mailer.rb")

    options = {}
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:project] = ENV['project'] if ENV['project']
    options[:tracker] = ENV['tracker'].to_i if ENV['tracker']
    options[:users] = (ENV['users'] || '').split(',').each(&:strip!)

    Mailer.with_synched_deliveries do
      Mailer.issue_reports(options)
    end
  end
end
