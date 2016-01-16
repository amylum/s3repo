require 'spec_helper'

describe S3Repo::Base do
  it 'accepts a parameter hash' do
    expect(S3Repo::Base.new({})).to be_an_instance_of S3Repo::Base
  end

  it 'has a private run method' do
    expect(subject.respond_to?(:run)).to be_falsey
  end
  it 'runs commands and returns their output' do
    expect(subject.send(:run, 'echo winner')).to eql "winner\n"
  end
  it 'raises if the run fails' do
    expect { subject.send(:run, 'false') }.to raise_exception RuntimeError
  end

  it 'has a private bucket param' do
    expect(subject.respond_to?(:bucket)).to be_falsey
  end
  describe 'provided bucket param' do
    it 'uses bucket from option' do
      expect(S3Repo::Base.new(bucket: 'foo').send(:bucket)).to eql 'foo'
    end
  end
  describe 'bucket set in ENV' do
    it 'uses bucket from ENV' do
      ClimateControl.modify S3_BUCKET: 'bar' do
        expect(S3Repo::Base.new.send(:bucket)).to eql 'bar'
      end
    end
  end
  describe 'no bucket set' do
    it 'raises an error' do
      expect { S3Repo::Base.new.send(:bucket) }.to raise_exception RuntimeError
    end
  end

  it 'has a private client method' do
    expect(subject.respond_to?(:client)).to be_falsey
  end
  describe 'a provided client' do
    it 'reuses the client' do
      expect(S3Repo::Base.new(client: 'foo').send(:client)).to eql 'foo'
    end
  end
  describe 'no provided client' do
    it 'creates the client' do
      ClimateControl.modify AWS_REGION: 'us-east-1' do
        base = S3Repo::Base.new(bucket: 'foo')
        expect(base.send(:client)).to be_an_instance_of S3Repo::Client
      end
    end
  end

  it 'has a private file_cache method' do
    expect(subject.respond_to?(:file_cache)).to be_falsey
  end
  describe 'a provided file_cache' do
    it 'reuses the file_cache' do
      base = S3Repo::Base.new(client: 'bar', file_cache: 'foo')
      expect(base.send(:file_cache)).to eql 'foo'
    end
  end
  describe 'no provided file_cache' do
    it 'creates the file_cache' do
      base = S3Repo::Base.new(client: 'foo')
      expect(base.send(:file_cache)).to be_an_instance_of S3Repo::Cache
    end
  end
end
