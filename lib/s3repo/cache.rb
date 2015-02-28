require 'fileutils'
require 'tempfile'

module S3Repo
  ##
  # Cache object, stores S3 objects on disk
  class Cache < Base
    TMPDIRS = [ENV['S3REPO_TMPDIR'], ENV['TMPDIR'], '/tmp/s3repo']

    def initialize(params = {})
      super
      FileUtils.mkdir_p(tmpdir)
    end

    def serve(path, recheck = true)
      epath = expand_path(path)
      prune(epath) if recheck
      download(path, epath) unless File.exist?(epath)
      File.open(epath) { |fh| fh.read }
    end

    private

    def expand_path(path)
      File.absolute_path(path, cachedir)
    end

    def cached?(epath)
      File.exist? epath
    end

    def download(path, epath)
      tmpfile = Tempfile.create(path.split('/').last, partialdir)
      tmpfile << client.get_object(path).body.read
      FileUtils.mkdir_p File.dirname(epath)
      File.rename tmpfile.path, epath
    end

    def prune(epath)
      return unless cached? epath
      current = File.readlink(epath).split('-').last
      new = client.head_object(key: path).etag.gsub('"', '')
      return if new == current
      [epath, File.readlink(epath)].each { |x| File.unlink x }
    end

    def cachedir
      File.join(tmpdir, 'cache')
    end

    def partialdir
      File.join(tmpdir, 'partial')
    end

    def tmpdir
      @tmpdir ||= File.absolute_path(@options[:tmpdir] || TMPDIRS.compact.first)
    end
  end
end
