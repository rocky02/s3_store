class S3Object

  attr_reader :aws_obj, :bucket

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
    begin
      result = nil
      case options[:operation]
      when 'copy'
        result = copy(options[:destination], options[:key])
      when 'upload'
        result = upload(options[:source], options[:key])
      when 'download'
        result = download(options[:key], options[:destination])
      end
      
      if result
        Application.log.info "Copy from #{options[:source]} to #{options[:destination]} completed successfully."
        puts "Copy from #{options[:source]} to #{options[:destination]} completed successfully.".colorize(:green)
      end
    
    rescue Aws::S3::Errors::NoSuchBucket => e
      handle_error(e)
    rescue Aws::S3::Errors::PermanentRedirect => e
      handle_error(e)
    rescue Aws::S3::Errors::InvalidRequest => e
      handle_error(e)
    end        
  end

  def local_to_local?(source, destination)
    !is_s3_bucket?(source) && !is_s3_bucket?(destination)
  end

  def is_s3_bucket?(file)
    file.match?(App::BUCKET_URI_REGEX)
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
