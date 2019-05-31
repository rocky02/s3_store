require 'byebug'
RSpec.describe Store do
  let (:s3) { Aws::S3::Client.new(stub_responses: true) }
  let (:s3_store) { Store.new }
  
  before do
    allow(s3_store).to receive(:client).and_return(s3)
  end
  
  context '#list_buckets' do
    
    it 'should list all the buckets in the linked account when response is not empty/nil' do
      s3.stub_responses(:list_buckets, buckets: [{ name: 'bucket1' }, { name: 'bucket2' }, { name: 'bucket3' }])
      response = s3.list_buckets
      expect(s3_store).to receive(:list_buckets).and_return(response)
      s3_store.list_buckets
    end
    
    it 'display message when there are no buckets - empty / nil response' do
      s3.stub_responses(:list_buckets, buckets: [])
      expect { s3_store.list_buckets }.to raise_error(S3StoreEmptyError)
    end
  end

  context '#create_bucket' do
    
    let (:bucket_name) { "foobar007" }
    let (:invalid_bucket_name) { "TestBucket!" }
    
    before do
      s3.stub_responses(:create_bucket)
    end

    it 'should create a new bucket with bucket name' do
      expect(s3_store).to receive(:create_bucket).with(bucket_name)
      s3_store.create_bucket(bucket_name)
    end

    it 'should rescue Aws::S3::Errors::InvalidBucketName' do
      s3_store.stub(:create_bucket).and_raise('Aws::S3::Errors::InvalidBucketName')
      expect { s3_store.create_bucket(invalid_bucket_name) }.to raise_error('Aws::S3::Errors::InvalidBucketName')
    end

    it 'should rescue Aws::S3::Errors::BucketAlreadyOwnedByYou' do
      s3_store.stub(:create_bucket).and_raise('Aws::S3::Errors::BucketAlreadyOwnedByYou')
      expect { s3_store.create_bucket(invalid_bucket_name) }.to raise_error('Aws::S3::Errors::BucketAlreadyOwnedByYou')
    end
  end
end
