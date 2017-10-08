require 'fileutils'
require 'tempfile'

module S3Repo
  ##
  # Metadata object, represents repo's DB file
  class Metadata < Base
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
      client.upload_file('repo.db.tar.xz', db_path)
    end

    def packages
      return @packages if @packages
      cmd = "bsdtar tf #{db_path}"
      @packages = run(cmd).split.map { |x| x.split('/').first }.uniq
    end

    private

    def signer
      @options[:signer] ||= Signer.new(@options)
    end

    def sign_db
      sig_path = signer.sign(db_path)
      client.upload_file('repo.db.sig', sig_path)
      client.upload_file('repo.db.tar.xz.sig', sig_path)
    end

    def db_path
      @db_path ||= file_cache.download('repo.db.tar.xz')
    end
  end
end
