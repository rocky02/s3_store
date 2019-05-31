require 'yaml'
module AwsLoader

  AWS = YAML.load(File.read(Application.aws_config_file_path))['aws'] if File.exists?(Application.aws_config_file_path)

  def config_folder_check
    unless File.directory?(Application.root + '/config')
      FileUtils.mkdir_p(Application.root + '/config')[0]
    end
  end

  def yml_file_check
    if File.exists?(Application.aws_config_file_path)
      file_content = YAML.load(File.read(Application.aws_config_file_path))
      if !file_content || file_content.values.any?(&:empty?)
        puts "Fill in the appropriate values for the aws.yml file".colorize(:light_red)
        exit(1)
      end
    else
      puts 'Missing aws.yml file!'.colorize(:yellow)
      sample_aws = {"aws"=>{"access_key_id"=>"", "secret_access_key"=>"", "region"=>""}}
      File.open(Application.aws_config_file_path, 'w') do |file|
        file.puts sample_aws.to_yaml
      end
      puts 'aws.yml file created...'.colorize(:yellow)
      puts "Fill in the appropriate values for the aws.yml file.".colorize(:red)
      exit(1) 
    end
  end

  def configure_aws_file
    config_folder_check
    yml_file_check
  end
end
