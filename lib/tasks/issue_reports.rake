desc <<-END_DESC
Send issue reports via email.

Example:
  rake redmine:send_issue_reports RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_issue_reports => :environment do
    puts 'not yet implemented'
  end
end
