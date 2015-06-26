module IssueReports
  module UserPreferencePatch
    def self.included(base)
      base.class_eval do
        def dont_receive_issue_reports
          self[:dont_receive_issue_reports] || false
        end

        def dont_receive_issue_reports=(value)
          self[:dont_receive_issue_reports] = value
        end
      end
    end
  end
end
