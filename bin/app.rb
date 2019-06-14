require_relative '../boot'
class App
  include AwsLoader

  OPERATIONS = ['create', 'delete', 'list', 'copy']
  BUCKET_URI_REGEX = /^(s3:\/\/)/

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
      raise S3StoreArgumentError, "S3StoreArgumentError:: insufficient arguments" if options.count != 2

      copy_params = extract_params(options)
      bucket_name = copy_params[:bucket]
      s3_obj = S3Object.new(bucket_name)
      s3_obj.perform_operation(copy_params)
    else
      raise S3StoreNoServiceError, "Invalid operation name. Try #{OPERATIONS.join(', ')}.".colorize(:red) if (operation.nil? || !OPERATIONS.include?(operation.downcase))
    end  
  end

  def extract_params(options)
    source, destination, bucket = nil, nil, nil

    source_file = File.basename(options[0])

    if options[0].match?(BUCKET_URI_REGEX) && options[1].match?(BUCKET_URI_REGEX) # copy bucket-to-bucket
      source = extract_s3_bucket(options[0])
      destination = extract_s3_bucket(options[1])
      bucket = source
    elsif !options[0].match?(BUCKET_URI_REGEX) # upload from local-to-bucket
      source = options[0]
      destination = extract_s3_bucket(options[1])
      bucket = destination
    else # download from bucket-to-local
      source = extract_s3_bucket(options[0])
      destination = options[1]
      bucket = source
    end    
    
    { source: source, destination: destination, key: source_file, bucket: bucket }
  end
  
  def extract_s3_bucket(filepath)
    bucket = filepath.gsub(BUCKET_URI_REGEX, '')
    bucket.split('/')[0]
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
