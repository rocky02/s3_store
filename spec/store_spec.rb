RSpec.describe Store do
  let (:s3) { Aws::S3::Client.new(stub_responses: true) }
  let (:s3_store) { Store.new }
  
  before do
    allow(s3_store).to receive(:aws_client).and_return(s3)
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
    let (:response) { double('response') }
    
    before do
      s3.stub_responses(:create_bucket)
    end

    it 'should create a new bucket with bucket name' do
      expect(s3_store).to receive(:create_bucket).with(bucket_name)
      expect(s3).to receive(:create_bucket).with({bucket: bucket_name}).and_return(response)
      s3.create_bucket({bucket: bucket_name})
      s3_store.create_bucket(bucket_name)
    end

    it 'should rescue Aws::S3::Errors::InvalidBucketName' do
      expect { s3_store.create_bucket(invalid_bucket_name) }.to raise_error(S3StoreArgumentError)
    end

    it 'should rescue Aws::S3::Errors::BucketAlreadyOwnedByYou' do
      allow(s3_store).to receive(:create_bucket).and_raise('Aws::S3::Errors::BucketAlreadyOwnedByYou')
      expect { s3_store.create_bucket(invalid_bucket_name) }.to raise_error('Aws::S3::Errors::BucketAlreadyOwnedByYou')
    end
  end

  context '#no_bucket?(response)' do
    let (:response) { double('response') }

    context 'when response is nil' do
      it 'should be true' do
        allow(response).to receive(:nil?).and_return(true)
        expect(s3_store.no_buckets?(response)).to be_truthy
      end
    end

    context 'when response.buckets is empty' do
      it 'should be true' do
        allow(response).to receive(:buckets).and_return([])
        expect(s3_store.no_buckets?(response)).to be_truthy
      end
    end

    context 'when there are buckets in the s3 store' do
      it 'should be false' do
        allow(response).to receive(:buckets).and_return(['bucket-1', 'bucket-2'])
        expect(s3_store.no_buckets?(response)).to be_falsey
      end
    end
  end
end
