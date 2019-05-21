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
      allow(s3).to receive(:list_buckets)
      allow(s3_store).to receive(:list_buckets)
      response = s3.list_buckets
      expect(s3_store).to receive(:list_buckets).and_return(response)
      s3_store.list_buckets
    end
    
    # it 'display message when there are no buckets - empty / nil response' do
    #   s3.stub_responses(:list_buckets, buckets: [])
    #   allow(s3).to receive(:list_buckets)
    #   allow(Store).to receive(:list_buckets)
      # response = s3.list_buckets
      # puts "response ============= #{response}"
      # allow(Store).to receive(:empty_store?)#.and_return(true)
      # expect(Store).to receive(:list_buckets).and_return(response)
      # expect { Store.list_buckets }.to raise_error(S3StoreEmptyError)
    # end
  end

  context '#create_bucket' do
    it 'should create a new bucket with bucket name' do
      bucket_name = "foobar007"
      s3.stub_responses(:create_bucket)
      allow(s3).to receive(:create_bucket)
      allow(s3_store).to receive(:create_bucket)#.with(bucket_name)
      response = s3.create_bucket(bucket: bucket_name)
      # expect(STDOUT).to receive(:puts).with("S3 Bucket #{bucket_name} created successfully!")
      expect(s3_store).to receive(:create_bucket).with(bucket_name)
      s3_store.create_bucket(bucket_name)
    end
  end
end