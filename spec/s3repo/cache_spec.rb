require 'spec_helper'

describe S3Repo::Cache do
  it 'serves a file', vcr: { cassette_name: 'cache' } do
    with_auth do
      resp = S3Repo::Cache.new.serve('repo.db')
      expect(resp).to be_an_instance_of String
    end
  end

  context 'by default' do
    it 'does not caches the file', vcr: { cassette_name: 'cache' } do
      with_auth do
        cache = S3Repo::Cache.new
        cache.serve('repo.db')
        expect { cache.serve('repo.db') }.to raise_exception(
          VCR::Errors::UnhandledHTTPRequestError
        )
      end
    end
  end
  context 'with refresh = false' do
    it 'caches the file', vcr: { cassette_name: 'cache' } do
      with_auth do
        cache = S3Repo::Cache.new
        cache.serve('repo.db')
        expect(cache.serve('repo.db', false)).to be_an_instance_of String
      end
    end
  end
end
