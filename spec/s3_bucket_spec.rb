require 'byebug'
RSpec.describe S3Bucket do
  let (:aws_s3_client) { double('s3') }
  let (:s3) { Aws::S3::Client.new(stub_responses: true) }
  let (:s3_bucket) { S3Bucket.new('test-bucket-1')}
  
  before do
    allow(AwsS3Client).to receive(:new).and_return(aws_s3_client)
    allow(aws_s3_client).to receive(:client).and_return(s3)
  end
  
  context '#list_buckets' do
    
    it 'should list all the buckets in the linked account when response is not empty/nil' do
      s3.stub_responses(:list_buckets, buckets: [{ name: 'bucket1' }, { name: 'bucket2' }, { name: 'bucket3' }])
      allow(s3).to receive(:list_buckets)
      allow(S3Bucket).to receive(:list_buckets)
      response = s3.list_buckets
      expect(S3Bucket).to receive(:list_buckets).and_return(response)
      S3Bucket.list_buckets
    end
    
    # it 'display message when there are no buckets - empty / nil response' do
    #   s3.stub_responses(:list_buckets, buckets: [])
    #   allow(s3).to receive(:list_buckets)
    #   allow(S3Bucket).to receive(:list_buckets)
      # response = s3.list_buckets
      # puts "response ============= #{response}"
      # allow(s3_bucket).to receive(:empty_store?)#.and_return(true)
      # expect(S3Bucket).to receive(:list_buckets).and_return(response)
      # expect { S3Bucket.list_buckets }.to raise_error(S3StoreEmptyBucketError)
    # end
  end

  context '#create_bucket' do
    it 'should create a new bucket with bucket name' do
      bucket_name = "foobar007"
      s3.stub_responses(:create_bucket)
      allow(s3).to receive(:create_bucket)
      allow(s3_bucket).to receive(:create_bucket)
      response = s3.create_bucket(bucket: bucket_name)
      expect(STDOUT).to receive(:puts).with("S3 Bucket #{bucket_name} created successfully!")
      s3_bucket.create_bucket
    end
  end
end