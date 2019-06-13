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
      result = aws_obj.client.copy_object(bucket: destination_bucket, copy_source: "#{bucket}/#{filename}", key: filename)
      if result
        Application.log.info "Object copied from #{bucket} to #{destination_bucket} - #{result}"
        puts "#{filename} copied successfully to #{destination_bucket}!".colorize(:green)
      end
    rescue Aws::S3::Errors::PermanentRedirect => e
      handle_error(e)
    end
  end

  def upload(filepath, key=nil)
    begin
      key = File.basename(filepath) if key.nil? || key.empty?
      obj = aws_obj.resource.bucket(bucket).object(key)
      if obj.upload_file(filepath)
        Application.log.info "#{key} upload successful! :: #{obj}"
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
      result = aws_obj.client.get_object({ bucket: bucket, key:key }, target: destination_path)
      if result
        Application.log.info "#{key} copied to #{destination_path} successfully."
        puts "#{key} copied to #{destination_path} successfully."
      end
    rescue Aws::S3::Errors::PermanentRedirect => e
      handle_error(e)
    end
  end

  def perform_operation(params={})
    options = sanitize_params(params)

    raise S3ObjectOperationError, "S3ObjectOperationError :: Source or Destination or both files must belong to a S3 bucket." if invalid_file_options?(options[:source], options[:destination])
    if file_is_local?(options[:source]) && object_from_bucket?(options[:destination])
      upload(options[:source], options[:key])
    elsif file_is_local?(options[:destination]) && object_exists?(options[:source])
      download(options[:key], options[:destination])
    else
      copy(options[:destination], options[:key])
    end
  end

  def invalid_file_options?(source, destination)
    !(source.match?(FILEPATH_REGEX) && destination.match?(FILEPATH_REGEX))
  end

  def file_is_local?(file)
    file.match?(FILEPATH_REGEX) && !valid_bucket_name?(file)
  end

  def object_from_bucket?(file)
    !file.match?(FILEPATH_REGEX) && valid_bucket_name?(file)
  end

  def valid_bucket_name?(bucket)
    Bucket.valid?(bucket)
  end

  def object_exists?(object)
    bucket = aws_obj.resource.bucket(bucket)
    bucket.object(object).exists?
  end

  protected
  
  def handle_error(error)
    Application.log.error(error)
    puts "Error :: #{error}".colorize(:red)
  end

  def sanitize_params(options={})
    key, source, destination = "", "", ""
    options[:params].each do |param|
      key = param.split(':')[1] if param.match?(/key/)
      source = param.split(':')[1] if param.match?(/source/)
      destination = param.split(':')[1] if param.match?(/destination/)
    end
    { key: key, source: source, destination: destination }
  end
end
