require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe S3Repo::Cache do
  it 'serves a file', vcr: { cassette_name: 'cache' } do
    with_auth do
      resp = S3Repo::Cache.new.serve('repo.db')
      expect(resp).to be_an_instance_of String
    end
  end

  context 'by default' do
    it 'tries to cache the file', vcr: { cassette_name: 'cache' } do
      with_auth do
        cache = S3Repo::Cache.new
        cache.serve('repo.db')
        expect { cache.serve('repo.db') }.to raise_exception(
          VCR::Errors::UnhandledHTTPRequestError
        )
      end
    end
    it 'checks etag for caching', vcr: { cassette_name: 'etag_cache' } do
      with_auth do
        cache = S3Repo::Cache.new
        res = (1..2).map do
          cache.serve('repo.db')
          cache.send(:etags)['repo.db']
        end
        expect(res.first).to eql res.last
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

  it 'returns nil if key does not exist', vcr: { cassette_name: 'nil_cache' } do
    with_auth do
      cache = S3Repo::Cache.new
      expect(cache.serve('nonexistent-file')).to be_nil
    end
  end
end
