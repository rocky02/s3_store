RSpec.describe S3Bucket do
  context '#list_buckets' do
    let (:aws_s3_client) { double('sqs') }
    let (:client) { double('client') }
    let (:s3) { Aws::S3::Client.new(stub_responses: true) }
    let (:s3_bucket) { S3Bucket.new('test-bucket-1')}

    before do
      allow(aws_s3_client).to receive(:client).and_return(s3)
      allow(AwsS3Client).to receive(:new).and_return(aws_s3_client)
    end

    it 'should list all the buckets in the linked account' do
      client.stub_responses(:list_buckets, buckets: [{ name: 'bucket1' }, { name: 'bucket2' }, { name: 'bucket3' }])
      allow(aws_s3_client).to receive(:list_buckets)
      response = client.list_buckets
      expect(aws_s3_client).to receive(:list_buckets).and_return(result)
      S3Bucket.list_buckets
    end

  end
end