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

require 's3repo/repo'
