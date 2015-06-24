Redmine::Plugin.register :redmine_issue_reports do
  name 'Redmine Issue Reports plugin'
  author 'Dennis Klein <d.klein@gsi.de>'
  description 'Send issue report emails'
  version '0.0.1'
  url 'https://github.com/dennisklein/redmine_issue_reports'
  author_url 'https://github.com/dennisklein'
  requires_redmine :version_or_higher => '2.5.0'
end
