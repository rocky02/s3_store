class Store

  attr_reader :aws_client
  
  def initialize
    app = Application.new
    @aws_client = app.client
  end
  
  def create_bucket(bucket_name)
    raise S3StoreArgumentError, "S3StoreArgumentError :: Invalid bucket name.".colorize(:red) if bucket_name.nil?
    begin
      response = aws_client.create_bucket({bucket: bucket_name})
      puts "S3 Bucket #{bucket_name} created successfully!".colorize(:green) unless response.nil?
    rescue Aws::S3::Errors::InvalidBucketName => e
      puts "Bucket name #{bucket_name} is invalid".colorize(:red)
    rescue Aws::S3::Errors::BucketAlreadyOwnedByYou => e
      puts "Bucket with name #{bucket_name} already exists in your S3 account.".colorize(:yellow)
    end
  end

  def list_buckets
    response = aws_client.list_buckets
    raise S3StoreEmptyError, 
          "S3StoreEmptyError :: You don't seem to have any buckets in your linked AWS S3 account. You may create one by using the command :: ".colorize(:light_blue) + " bin/s3_store_server create <bucket-name>".colorize(:yellow).bold if no_buckets?(response)

      bucket_names = response.buckets.map(&:name)
      bucket_names.each { |name| puts name.colorize(:yellow) }
  end

  def no_buckets?(response)
    response.nil? || response.buckets.empty?
  end
end
