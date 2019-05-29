require 'yaml'
module AwsLoader
  
  AWS_PATH = if File.directory?(Application.root + '/config')
               File.join(Application.root, 'config/aws.yml') 
             else
               FileUtils.mkdir_p(Application.root + '/config')[0]
             end
  AWS = YAML.load(File.read(AWS_PATH))["aws"] if File.exists?(AWS_PATH)

  def generate_aws_yml_file
    sample_aws = {"aws"=>{"access_key_id"=>"", "secret_access_key"=>"", "region"=>""}}
    File.open(AWS_PATH, 'w') do |file|
      file.puts sample_aws.to_yaml
    end
  end

  def configure_aws_file
    begin
      if File.exists?(AWS_PATH)
        aws = YAML.load(File.read(AWS_PATH))["aws"]
        if aws.values.any?(&:empty?)
          puts "Fill in the appropriate values for the aws.yml file".colorize(:light_red)
          exit 1
        end 
      else
        puts "No `aws.yml` file present!".colorize(:red)
        generate_aws_yml_file
        puts "Created file and set the appropriate values!".colorize(:red)
        exit 1
      end
    rescue => e
      puts "Exception with aws.yml file #{e.inspect}".colorize(:light_red)
    end
  end
end

# Dummy class for RSpec testing purposes
class ModuleTest
  include AwsLoader
end
