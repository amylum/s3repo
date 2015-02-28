require 'fileutils'
require 'tempfile'
require 'basiccache'

module S3Repo
  ##
  # Cache object, stores S3 objects on disk
  class Cache < Base
    TMPDIRS = [ENV['S3REPO_TMPDIR'], ENV['TMPDIR'], '/tmp/s3repo']

    def initialize(params = {})
      super
      [partialdir, cachedir].each { |x| FileUtils.mkdir_p x }
    end

    def serve(path, recheck = true)
      epath = expand_path(path)
      prune(path, epath) if recheck
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
      FileUtils.mkdir_p File.dirname(epath)
      tmpfile, etag = safe_download(path)
      etag_path = "#{epath}-#{etag}"
      File.rename tmpfile.path, etag_path
      File.symlink(etag_path, epath)
    end

    def safe_download(path)
      tmpfile = Tempfile.create(path.split('/').last, partialdir)
      object = client.get_object(key: path)
      tmpfile << object.body.read
      tmpfile.close
      [tmpfile, parse_etag(object)]
    end

    def parse_etag(object)
      tag = object.etag.gsub('"', '')
      return tag if tag.match(/^\h+$/)
      fail('Invalid etag')
    end

    def prune(path, epath)
      return unless cached? epath
      current = File.readlink(epath).split('-').last
      new = parse_etag client.head_object(key: path)
      return if new == current
      [File.readlink(epath), epath].each { |x| File.unlink x }
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
