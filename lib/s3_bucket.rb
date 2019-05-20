require 'byebug'

class S3Bucket

  attr_reader :bucket_name
  
  @@client ||= AwsS3Client.new.client

  def self.client
    @@client
  end
  
  def initialize(name)
    @bucket_name = name
  end

  def create_bucket
    raise S3StoreArgumentError, "S3StoreArgumentError :: Invalid bucket name.".colorize(:red) if bucket_name.nil?
    begin
      response = @@client.create_bucket({bucket: bucket_name})
      puts "S3 Bucket #{bucket_name} created successfully!".colorize(:green) unless response.nil?
    rescue Aws::S3::Errors::InvalidBucketName => e
      raise S3StoreArgumentError, "S3StoreArgumentError :: InvalidBucketName :: Bucket name #{bucket_name} is invalid".colorize(:red)
    rescue Aws::S3::Errors::BucketAlreadyOwnedByYou => e
      raise S3StoreArgumentError, "S3StoreArgumentError :: BucketAlreadyOwnedByYou :: Bucket with name #{bucket_name} already exists in your S3 account.".colorize(:red)
    end
  end

  def self.list_buckets
    response = @@client.list_buckets
    raise S3StoreEmptyBucketError, 
          "S3StoreEmptyBucketError :: You don't seem to have any buckets in your linked AWS S3 account. You may create one by using the command :: ".colorize(:light_blue) + " bin/s3_store_server create <bucket-name>".colorize(:yellow).bold if empty_store?(response)

      bucket_names = response.buckets.map(&:name)
      bucket_names.each { |name| puts name.colorize(:yellow) }
  end

  def delete_bucket
    begin
      raise S3StoreArgumentError, 'S3StoreArgumentError :: Incorrect argument. bucket_name is mandatory!'.colorize(:red) if bucket_name.empty? || bucket_name.nil?
      response = S3Bucket.client.delete_bucket({bucket: bucket_name})
      puts "Bucket #{bucket_name} deleted successfully!".colorize(:green) unless response.nil?
    rescue Aws::S3::Errors::NoSuchBucket => e
      puts "Aws::S3::Errors::NoSuchBucket :: #{bucket_name} does not exist!".colorize(:red)
    end
  end

  def empty_store?(response)
    response.buckets.empty? || response.nil?
  end

end