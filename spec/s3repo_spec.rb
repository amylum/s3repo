require 'spec_helper'

describe S3Repo do
  describe '#new' do
    it 'creates repo objects' do
      expect(S3Repo.new).to be_an_instance_of S3Repo::Repo
    end
  end
end
