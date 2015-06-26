module IssueReports
  class HookListener < Redmine::Hook::ViewListener
    render_on :view_my_account_preferences, :partial => 'issue_reports/user_preferences'

    def view_layouts_base_html_head(context = {})
      stylesheet_link_tag 'issue_reports.css', :plugin => 'redmine_issue_reports'
    end
  end
end
