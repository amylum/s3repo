module S3Repo
  ##
  # Package object, represents a single package tarball
  class Package < Base
    private

    def info
      lines = `tar xOf #{@options[:file]} .PKGINFO`.split("\n")
      lines.reject! { |x| x.match(/^#/) }
      lines.map { |x| x.split(' = ', 2) }.to_h
    end
  end
end
