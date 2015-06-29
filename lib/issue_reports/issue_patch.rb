module IssueReports
  module IssuePatch
    def self.included(base)
      base.class_eval do
        scope :assigned, lambda {
          includes(:assigned_to).
          where("#{Issue.table_name}.assigned_to_id IS NOT NULL")
        }
        scope :due_in, lambda { |days|
          where("#{Issue.table_name}.due_date <= ?", days.day.from_now.to_date).
          order("#{Issue.table_name}.due_date ASC")
        }
        scope :assigned_to, lambda { |user_ids|
          where(:assigned_to_id => user_ids) if user_ids.present?
        }
        scope :project_id, lambda { |project|
          where(:project_id => project.id) if project
        }
        scope :tracker_id, lambda { |tracker|
          where(:tracker_id => tracker.id) if tracker
        }
        scope :last_activity_older_than, lambda { |days|
          where("#{Issue.table_name}.updated_on < ?", days.day.ago.to_date).
          order("#{Issue.table_name}.updated_on ASC")
        }
      end
    end
  end
end
