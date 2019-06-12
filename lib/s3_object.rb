class S3Object

  attr_accessor :bucket
  attr_reader :aws_obj

  FILEPATH_REGEX = "(\\\\?([^\\/]*[\\/])*)([^\\/]+)$"

  def initialize(bucket)
    @aws_obj = Application.new
    @bucket = bucket
  end

  def copy(destination_bucket,filename)
    begin
      result = aws_obj.resource.copy_object(bucket: destination_bucket, copy_source: "#{bucket}/#{filename}", key: filename)
      Application.log "Object copied from #{bucket} to #{destination_bucket} - #{result}"
      puts "#{filename} copied successfully to #{destination_bucket}!".colorize(:green)
    rescue Aws::S3::Errors::PermanentRedirect => e
      handle_error(e)
    end
  end

  def upload(filepath, key=nil)
    begin
      key = File.basename(filepath) if key.nil? || key.empty?
      obj = aws_obj.resource.bucket(bucket).object(key)
      if obj.upload_file(filepath)
        Application.log "#{key} upload successful! :: #{obj}"
        puts "File upload to #{bucket} successful!".colorize(:green)
      else 
        raise S3ObjectCopyError, "S3ObjectCopyError :: Unable to upload #{filepath}.".colorize(:red)
      end
    rescue Aws::S3::Errors::NoSuchBucket => e
      handle_error(e)
    rescue Aws::S3::Errors::PermanentRedirect => e
      handle_error(e)
    end
  end

  def download(key, destination_path)
    begin
      result = s3.get_object({ bucket: bucket, key:key }, target: destination_path)
    rescue Aws::S3::Errors::PermanentRedirect => e
      handle_error(e)
    end
  end

  protected
  
  def handle_error(error)
    Application.log(error)
    puts "Error :: #{error}".colorize(:red)
  end
end
