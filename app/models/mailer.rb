class Mailer
  def issue_report(user, issues, days)
    set_language_if_valid user.language
    @issues = issues
    @days = days
    @issues_url = url_for(:controller => 'issues', :action => 'index',
                                :set_filter => 1, :assigned_to_id => user.id,
                                :sort => 'due_date:asc')
    mail :to => user.mail,
      :subject => l(:mail_subject_reminder, :count => issues.size, :days => days)
  end

  # Sends issue reports to issue assignees
  # Available options:
  # * :days     => how many days in the future to remind about (defaults to 7)
  # * :tracker  => id of tracker for filtering issues (defaults to all trackers)
  # * :project  => id or identifier of project to process (defaults to all projects)
  # * :users    => array of user/group ids who should be reminded
  def self.issue_reports(options={})
    days = options[:days] || 7
    project = options[:project] ? Project.find(options[:project]) : nil
    tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil
    user_ids = options[:users]

    issues_by_assignee(days, project, tracker, user_ids).each do |assignee, issues|
      issue_report(assignee, issues, days).deliver if assignee.is_a?(User) && assignee.active?
    end
  end

  def self.issues_by_assignee(days, project, tracker, user_ids)
    issues_by_assignee = Issue.open.
                               on_active_project.
                               assigned.
                               due_in(days).
                               assigned_to(user_ids).
                               project_id(project).
                               tracker_id(tracker).
                               group_by(&:assigned_to)

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
