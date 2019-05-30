class Bucket

  attr_reader :bucket_name, :client
  
  def initialize(name)
    @client = Store.new.client
    @bucket_name = name
  end

  def self.valid?(bucket_name)
    regex = /(?=^.{3,63}$)(?!^(\d+\.)+\d+$)(^(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])$)/
    bucket_name.match?(regex)    
  end

  def delete_bucket
    begin
      raise S3StoreArgumentError, 'S3StoreArgumentError :: Incorrect argument. bucket_name is mandatory!'.colorize(:red) if bucket_name.nil? || bucket_name.empty?
      response = client.delete_bucket({bucket: bucket_name})
      puts "Bucket #{bucket_name} deleted successfully!".colorize(:green) unless response.nil?
    rescue Aws::S3::Errors::NoSuchBucket => e
      puts "Aws::S3::Errors::NoSuchBucket :: #{bucket_name} does not exist!".colorize(:red)
    end
  end
end
