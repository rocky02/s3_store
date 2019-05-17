class AwsS3Client

  attr_reader :client
  
  def initialize 
    creds = Aws::Credentials.new(AwsLoader::AWS["access_key_id"], AwsLoader::AWS["secret_access_key"])
    @client = Aws::S3::Client.new(region: AwsLoader::AWS["region"], credentials: creds)
  end
end
