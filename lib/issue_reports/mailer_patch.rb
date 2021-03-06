module IssueReports
  module MailerPatch
    def self.included(base)
      base.class_eval do
        def issue_report(user, days, period, inactive_days, issues_due, issues_without_due_date, issues_inactive)
          set_language_if_valid user.language
          @issues_due = issues_due || []
          @issues_without_due_date = issues_without_due_date || []
          @issues_inactive = issues_inactive || []
          @days = days
          @inactive_days = inactive_days
          @issues_url = url_for(:controller => 'issues',
                                :action => 'index',
                                :set_filter => 1,
                                :assigned_to_id => user.id,
                                :sort => 'due_date:asc')
          @now = Time.zone.now
          @today = Date.today
          apptitle = Setting.app_title
          mailtitle = case period
          when 'd'
            l(:mail_subject_issue_report_daily)
          when 'w'
            l(:mail_subject_issue_report_weekly)
          when 'm'
            l(:mail_subject_issue_report_monthly)
          else
            l(:mail_subject_issue_report)
          end

          mail :to => user.mail,
               :subject => "[#{apptitle}] #{mailtitle}"
        end

        # Sends issue reports to issue assignees
        # Available options:
        # * :days     => how many days in the future to remind about (defaults to 7)
        # * :tracker  => id of tracker for filtering issues (defaults to all trackers)
        # * :project  => id or identifier of project to process (defaults to all projects)
        # * :users    => array of user/group ids who should be reminded
        # * :period   => mail subject: d=daily, w=weekly, m=monthly
        # * :inactive_days => how many days of inactive issues to report about (defaults to 7)
        def self.issue_reports(options={})
          days = options[:days] || 7
          project = options[:project] ? Project.find(options[:project]) : nil
          tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil
          user_ids = options[:users]
          period = options[:period] || nil
          inactive_days = options[:inactive_days] || 7

          issues_due = expand_groups(
            Issue.open.on_active_project.assigned.
            due_in(days).
            assigned_to(user_ids).project_id(project).
            tracker_id(tracker).group_by(&:assigned_to)
          )
          issues_without_due_date = expand_groups(
            Issue.open.on_active_project.assigned.
            where(:due_date => nil).
            assigned_to(user_ids).project_id(project).
            tracker_id(tracker).group_by(&:assigned_to)
          )
          issues_inactive = expand_groups(
            Issue.open.on_active_project.assigned.
            last_activity_older_than(inactive_days).
            assigned_to(user_ids).project_id(project).
            tracker_id(tracker).group_by(&:assigned_to)
          )
          (issues_due.keys +
           issues_without_due_date.keys +
           issues_inactive.keys).uniq.each do |assignee|
            if assignee.is_a?(User) &&
               assignee.active? &&
               assignee.pref.dont_receive_issue_reports == '0'
              issue_report(assignee, days, period, inactive_days,
                           issues_due[assignee],
                           issues_without_due_date[assignee],
                           issues_inactive[assignee]
                          ).deliver
              puts "[#{Time.now}] Issue report sent to #{assignee.login} (#{assignee.mail})"
            end
          end
        end

        def self.expand_groups(issues_by_assignee)
          issues_by_assignee.keys.each do |assignee|
            if assignee.is_a?(Group)
              assignee.users.each do |user|
                issues_by_assignee[user] ||= []
                issues_by_assignee[user] += issues_by_assignee[assignee]
              end
            end
          end
          issues_by_assignee
        end
      end
    end
  end
end
