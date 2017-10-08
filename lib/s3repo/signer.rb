module S3Repo
  ##
  # Signer object, signs files w/ GPG
  class Signer < Base
    def sign(path)
      sig_path = path + '.sig'
      run "gpg --detach-sign --local-user '#{key}' #{path}"
      sig_path
    end

    private

    def key
      @options[:key] || raise('no key ID set')
    end
  end
end
