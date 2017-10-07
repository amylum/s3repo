require 'fileutils'
require 'tempfile'

module S3Repo
  ##
  # Metadata object, represents repo's DB file
  class Metadata < Base
    def initialize(params = {})
      super
      FileUtils.mkdir_p db_dir
    end

    def add_packages(paths)
      @db_path = nil
      paths.each do |path|
        puts "Adding #{File.basename(path)} to repo.db"
        run("repo-add #{db_path} #{path}")
      end
      update!
    end

    def remove_packages(packages)
      @db_path = nil
      packages.each do |package|
        puts "Removing #{package} from repo.db"
        run("repo-remove #{db_path} #{package}")
      end
      update!
    end

    def update!
      sign_db if @options[:sign_db]
      client.upload_file('repo.db', db_path)
    end

    def packages
      return @packages if @packages
      cmd = "tar tf #{db_path}"
      @packages = run(cmd).split.map { |x| x.split('/').first }.uniq
    end

    private

    def sign_db
      run "gpg --detach-sign --use-agent #{db_path}"
      client.upload_file('repo.db.sig', "#{db_path}.sig")
    end

    def db_path
      @db_path ||= file_cache.download('repo.db')
    end
  end
end
