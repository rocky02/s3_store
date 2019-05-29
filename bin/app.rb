require_relative '../boot'
class App
  include AwsLoader

  OPERATIONS = ['create', 'delete', 'list']

  def execute_operation(options)
    operation = options.delete_at(0)
    bucket_name = options[0]
    
    case operation
    when 'create'
      if Bucket.valid?(bucket_name)
        store = Store.new
        store.create_bucket(bucket_name)
      else
        raise Aws::S3::Errors::InvalidBucketName, "Aws::S3::Errors::InvalidBucketName :: Invalid bucket name".colorize(:red)
      end
    when 'delete'
      s3_bucket = Bucket.new(bucket_name)
      s3_bucket.delete_bucket
    when 'list'
      store = Store.new
      store.list_buckets
    else
      raise S3StoreNoServiceError, "Invalid operation name. Try #{OPERATIONS.join(', ')}.".colorize(:red) if (operation.nil? || !OPERATIONS.include?(operation.downcase))
    end  
  end
end

# Beginning of execution of App.
options = ARGV
operation = options[0]
raise S3StoreArgumentError, "Wrong Arguments. Check documentation on how to run the operation.".colorize(:red) if options.length < 1

begin
  app = App.new
  app.configure_aws_file
  puts "Beginning operation execution...".colorize(:cyan)
  app.execute_operation(options)
rescue ArgumentError => e
  puts "There is an exception in the #{operation} operation #{e.inspect}".colorize(:red)
end
