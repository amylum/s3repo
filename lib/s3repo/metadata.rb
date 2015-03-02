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
        run("repo-add #{db_path} #{path}")
      end
      client.upload!('repo.db', db_path)
    end

    private

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
