require 'fileutils'
require 'tmpdir'
require 'tempfile'

module S3Repo
  ##
  # Cache object, stores S3 objects on disk
  class Cache < Base
    TMPDIRS = [
      ENV['TMPDIR'],
      Dir.tmpdir,
      '/tmp/s3repo'
    ].freeze

    def initialize(params = {})
      super
      [partialdir, cachedir].each { |x| FileUtils.mkdir_p x }
    end

    def download(key, refresh = true)
      path = expand_path key
      get_object(key, path) if refresh || !cached?(path)
      path
    end

    private

    def file_cache
      raise('Tried to call file_cache recursively')
    end

    def expand_path(key)
      File.absolute_path(key, cachedir)
    end

    def cached?(path)
      File.exist? path
    end

    def get_object(key, path)
      FileUtils.mkdir_p File.dirname(path)
      object = atomic_get_object(key, path)
      etags[key] = object.etag
    rescue Aws::S3::Errors::NotModified # rubocop:disable Lint/HandleExceptions
    end

    def atomic_get_object(key, path)
      tmpfile = Tempfile.create(key, partialdir)
      object = client.get_object(
        key: key, if_none_match: etags[key], response_target: tmpfile
      )
      tmpfile.close
      File.rename tmpfile.path, path
      object
    end

    def etags
      @etags ||= {}
    end

    def cachedir
      File.join(tmpdir, 'cache')
    end

    def partialdir
      File.join(tmpdir, 'partial')
    end

    def tmpdir
      @tmpdir ||= Dir.mktmpdir 's3repo', tmpdir_root
    end

    def tmpdir_root
      @tmpdir_root ||= File.absolute_path(
        @options[:tmpdir] || TMPDIRS.compact.first
      )
    end
  end
end
