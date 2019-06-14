class S3Object

  attr_reader :aws_obj, :bucket

  FILEPATH_REGEX = "(\\\\?([^\\/]*[\\/])*)([^\\/]+)$"

  def initialize(bucket)
    @aws_obj = Application.new
    @bucket = bucket
  end

  def copy(destination_bucket, key)
    aws_obj.client.copy_object(bucket: destination_bucket, copy_source: "#{bucket}/#{key}", key: key)
  end

  def upload(source_path, key=nil)
    obj = aws_obj.resource.bucket(bucket).object(key)
    response = obj.upload_file(source_path)
    raise S3ObjectCopyError, "S3ObjectCopyError :: Unable to upload #{source_path}.".colorize(:red) unless response
    response
  end

  def download(key, destination_path)
    aws_obj.client.get_object({ bucket: bucket, key:key }, target: "#{destination_path}/#{key}")
  end

  def perform_operation(options)
    raise S3ObjectOperationError, "S3ObjectOperationError :: Source or Destination or both files must belong to a S3 bucket." if local_to_local?(options[:source], options[:destination])

    begin
      result = if file_is_local?(options[:source]) && !file_is_local?(options[:destination])
                upload(options[:source], options[:key])
              elsif file_is_local?(options[:destination]) && object_exists?(options[:key])
                download(options[:key], options[:destination])
              else
                copy(options[:destination], options[:key])
              end
      
      if result
        Application.log.info "Copy from #{options[:source]} to #{options[:destination]} completed successfully."
        puts "Copy from #{options[:source]} to #{options[:destination]} completed successfully.".colorize(:green)
      end
    
    rescue Aws::S3::Errors::NoSuchBucket => e
      handle_error(e)
    rescue Aws::S3::Errors::PermanentRedirect => e
      handle_error(e)
    end        
  end

  def local_to_local?(source, destination)
    file_is_local?(source) && file_is_local?(destination)
  end

  def file_is_local?(file)
    !Bucket.valid?(file)
  end

  def object_exists?(object, bucket = self.bucket)
    bucket = aws_obj.resource.bucket(bucket)
    bucket.object(object).exists?
  end

  protected
  
  def handle_error(error)
    Application.log.error(error)
    puts "Error :: #{error}".colorize(:red)
  end
end
