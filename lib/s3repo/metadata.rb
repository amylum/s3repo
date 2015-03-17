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
      sign_db if ENV['S3REPO_SIGN_DB']
      client.upload!('repo.db', db_path)
    end

    private

    def sign_db
      run "gpg --detach-sign --use-agent #{db_path}"
      client.upload!('repo.db.sig', "#{db_path}.sig")
    end

    def db_path
      @db_path ||= download_db
    end

    def download_db
      tmpfile = Tempfile.create(['repo', '.db.tar.xz'], db_dir)
      tmpfile << file_cache.serve('repo.db')
      tmpfile.close
      tmpfile.path
    end

    def db_dir
      @db_dir ||= File.absolute_path(
        @options[:tmpdir] || Cache::TMPDIRS.compact.first
      )
    end
  end
end
