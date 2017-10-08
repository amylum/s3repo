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
      db_names.each { |x| client.upload_file(x, db_path) }
    end

    def packages
      return @packages if @packages
      cmd = "bsdtar tf #{db_path}"
      @packages = run(cmd).split.map { |x| x.split('/').first }.uniq
    end

    private

    def repo_name
      @options[:repo_name] || raise('No repo name given')
    end

    def db_names
      @db_names ||= ['repo', repo_name].flat_map do |x|
        [x + '.db', x + '.db.tar.xz']
      end
    end

    def sig_names
      @sig_names ||= db_names.map { |x| x + '.sig' }
    end

    def signer
      @options[:signer] ||= Signer.new(@options)
    end

    def sign_db
      sig_path = signer.sign(db_path)
      sig_names.each { |x| client.upload_file(x, sig_path) }
    end

    def db_path
      @db_path ||= file_cache.download(db_names.first)
    end
  end
end
