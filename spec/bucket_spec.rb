RSpec.describe Bucket do
  let (:bucket_name) { 'test-123' }
  let (:s3) { Aws::S3::Client.new(stub_responses: true) }
  let (:bucket) { Bucket.new(bucket_name) }

  before do
    allow(bucket).to receive(:client).and_return(s3)
  end

  context '#delete_bucket' do
    
    it 'should delete the bucket from the s3 store' do
      expect(bucket).to receive(:delete_bucket)
      bucket.delete_bucket
    end

    it 'should raise S3StoreArgumentError when bucket name is not provided' do
      invalid_bucket = Bucket.new('')
      expect { invalid_bucket.delete_bucket }.to raise_error(S3StoreArgumentError)
    end

    it 'should rescue Aws::S3::Errors::BucketAlreadyOwnedByYou' do
      bucket.stub(:delete_bucket).and_raise('Aws::S3::Errors::NoSuchBucket')
      expect { bucket.delete_bucket }.to raise_error('Aws::S3::Errors::NoSuchBucket')
    end

    it 'should rescue Aws::S3::Errors::PermanentRedirect' do
      bucket.stub(:delete_bucket).and_raise('Aws::S3::Errors::PermanentRedirect')
      expect { bucket.delete_bucket }.to raise_error('Aws::S3::Errors::PermanentRedirect')
    end
  end
end
