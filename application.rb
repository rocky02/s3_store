class Application

  attr_reader :client
  
  def initialize
    creds = Aws::Credentials.new(AwsLoader::AWS["access_key_id"], AwsLoader::AWS["secret_access_key"])
    @client = Aws::S3::Client.new(region: AwsLoader::AWS["region"], credentials: creds)
    @resource = Aws::S3::Resource.new(region: AwsLoader::AWS["region"], credentials: creds)
  end

  @@root ||= Dir.pwd
  
  class << self
    def root
      @@root
    end
  
    def log
        @@logger ||= Logger.new(File.join(@@root, 'log', 's3_store.log'))
      end

      def generate_log_file
        Dir.mkdir(File.join(Application.root, 'log')) unless File.exists?(File.join(Application.root, 'log'))
      end

    def aws_config_file_path
    	@@root + '/config/aws.yml'
    end
  end
end

Application.generate_log_file
