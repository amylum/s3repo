module S3Repo
  ##
  # Metadata object, represents a package DB
  class Metadata < Base
    def add_package(package)
      puts "Adding #{package}"
    end
  end
end
