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
      expect { bucket.delete_bucket }.to_not raise_error('Aws::S3::Errors::NoSuchBucket')
    end

    it 'should raise S3StoreArgumentError when bucket name is not provided' do
      invalid_bucket = Bucket.new('')
      expect { invalid_bucket.delete_bucket }.to raise_error(S3StoreArgumentError)
    end

    it 'should rescue Aws::S3::Errors::NoSuchBucket' do
      allow(bucket).to receive(:delete_bucket).and_raise('Aws::S3::Errors::NoSuchBucket')
      expect { bucket.delete_bucket }.to raise_error('Aws::S3::Errors::NoSuchBucket')
    end
  end

  context '#valid?(bucket_name)' do
    
    let(:valid_bucket_names) { ['test01', 'test-01', 'test.01'] }
    let(:invalid_bucket_names) { ['test_01', 'Test-01', '255.23.45.01', 'test@01'] }
    
    it 'should validate the name of the bucket against regex' do
      valid_bucket_names.each do |bucket_name|
        expect(Bucket.valid? bucket_name).to be_truthy
      end
      invalid_bucket_names.each do |bucket_name|
        expect(Bucket.valid? bucket_name).to be_falsey
      end
    end
  end
end
