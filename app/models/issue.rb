class Issue
  scope :assigned, lambda {
    includes(:assigned_to).
    where("#{Issue.table_name}.assigned_to_id IS NOT NULL")
  }
  scope :due_in, lambda { |days|
    where("#{Issue.table_name}.due_date <= ?", days.day.from_now.to_date)
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
end
