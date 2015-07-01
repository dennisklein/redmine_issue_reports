module IssueReports
  module VERSION
    MAJOR = 1
    MINOR = 1
    PATCH = 0

    # Retrieve branch from the working copy
    def self.branch
      res = self.git('rev-parse --abbrev-ref HEAD')
      res.strip unless res.nil?
    end

    # Retrieves the revision from the working copy
    def self.revision
      git_description = self.git 'describe --long --dirty --abbrev=10 --always'
      if git_description =~ /.*?-\d+-([0-9a-z-]+)/
        return $1
      elsif git_description =~ /.*?([0-9a-z]{10})/
        return $1
      end
      nil
    end

    def self.git(args)
      cwd = File.dirname(__FILE__)
      if File.directory?(File.join(cwd, '..', '..', '.git'))
        begin
          return Dir.chdir(cwd) { `git #{args}` }
        rescue
          # Silently fail
        end
      end
      nil
    end

    BRANCH = self.branch
    REVISION = self.revision
    case BRANCH
    when 'master'
      ARRAY = [MAJOR, MINOR, PATCH]
    else
      ARRAY = [MAJOR, MINOR, PATCH, BRANCH, REVISION].compact
    end
    STRING = ARRAY.join('.')

    def self.to_a
      ARRAY
    end

    def self.to_s
      STRING
    end
  end
end
