module IssueReportsAdminHelper
  def issue_reports_admin_tabs
    tabs = [{:name => 'user_settings', :partial => 'issue_reports_admin/user_settings', :label => :label_issue_reports_user_settings}]
  end
end
