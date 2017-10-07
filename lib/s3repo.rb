##
# This module provides a simple library for Archlinux repos in S3
module S3Repo
  class << self
    ##
    # Insert a helper .new() method for creating a new Repo object

    def new(*args)
      self::Repo.new(*args)
    end
  end
end

require 's3repo/version'
require 's3repo/base'
require 's3repo/metadata'
require 's3repo/cache'
require 's3repo/client'
require 's3repo/templates'
require 's3repo/repo'
