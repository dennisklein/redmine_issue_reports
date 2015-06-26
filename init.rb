Redmine::Plugin.register :redmine_issue_reports do
  name 'Redmine Issue Reports plugin'
  author 'Dennis Klein <d.klein@gsi.de>'
  description 'Send issue report emails'
  version IssueReports::VERSION.to_s
  url 'https://github.com/dennisklein/redmine_issue_reports'
  author_url 'https://github.com/dennisklein'
  requires_redmine :version_or_higher => '2.5.0'

  menu :admin_menu, :issue_reports, { :controller => 'issue_reports_admin', :action => 'index' }, :caption => :label_issue_reports
end

RedmineApp::Application.config.to_prepare do
  require_dependency 'issue_reports/user_preference_patch'
  require_dependency 'issue_reports/issue_patch'
  require_dependency 'issue_reports/mailer_patch'

  UserPreference.send(:include, IssueReports::UserPreferencePatch)
  Issue.send(:include, IssueReports::IssuePatch)
  Mailer.send(:include, IssueReports::MailerPatch)
end

#Hooks
require_dependency 'issue_reports/hook_listener'
