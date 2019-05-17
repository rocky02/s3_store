require_relative '../application_config'
require 'byebug'
class App
  include AwsLoader

  OPERATIONS = ['create', 'delete', 'list']

  def execute_operation(options)
    operation = options.delete_at(0)

    case operation
    when 'create'
      # S3Bucket.validate(options[0])
      publisher = S3Bucket.new(options[0])
      publisher.create_bucket
    when 'delete'
      # S3Bucket.validate(options)
      subscriber = S3Bucket.new(options[0])
      subscriber.delete_bucket
    when 'list'
      S3Bucket.list_buckets
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
