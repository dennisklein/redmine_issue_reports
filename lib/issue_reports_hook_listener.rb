class IssueReportsHookListener < Redmine::Hook::ViewListener
  render_on :view_my_account_preferences, :partial => 'issue_reports/user_preferences'
end
