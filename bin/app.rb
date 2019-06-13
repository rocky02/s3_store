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
        raise S3StoreInvalidArgumentError, "S3StoreInvalidArgumentError:: Invalid bucket name".colorize(:red)
      end
    when 'delete'
      s3_bucket = Bucket.new(bucket_name)
      s3_bucket.delete_bucket
    when 'list'
      store = Store.new
      buckets = store.list_buckets
      buckets.each { |name| puts name.colorize(:yellow) }
    when 'copy'
      raise S3StoreArgumentError, "S3StoreArgumentError:: insufficient arguments" if options.count != 4

      s3_obj = S3Object.new(bucket_name)
      s3_obj.perform_operation(options = { operation: 'copy', params: [options[1], options[2], options[3]] })
    else
      raise S3StoreNoServiceError, "Invalid operation name. Try #{OPERATIONS.join(', ')}.".colorize(:red) if (operation.nil? || !OPERATIONS.include?(operation.downcase))
    end  
  end
end

# Beginning of execution of App.
options = ARGV
puts options
raise S3StoreArgumentError, "Wrong Arguments. Check documentation on how to run the operation.".colorize(:red) if options.length < 1
operation = options[0]

begin
  app = App.new
  app.configure_aws_file
  puts "Beginning operation execution...".colorize(:cyan)
  app.execute_operation(options)
rescue ArgumentError => e
  puts "There is an exception in the #{operation} operation #{e.inspect}".colorize(:red)
end
