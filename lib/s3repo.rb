require 'aws-sdk'

##
# This module provides a simple library for Archlinux repos in S3
module S3Repo
  class << self
    ##
    # Insert a helper .new() method for creating a new Repo object

    def new(*args)
      self::Repo.new(*args)
    end

    def aws_client
      @aws_client ||= Aws::S3::Client.new
    end
  end
end

require 's3repo/package'
require 's3repo/metadata'
require 's3repo/repo'
