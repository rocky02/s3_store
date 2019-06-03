# Dummy class to test module AwsLoader
class TestModule
  include AwsLoader
end

RSpec.describe AwsLoader do
  let (:path) { File.dirname(Application.aws_config_file_path) }
  let (:aws_file) { Application.aws_config_file_path }
  let (:test_module) { TestModule.new }
  
  context '#config_folder_check' do

    it 'should create a config directory' do
      allow(File).to receive(:directory?).with(path).and_return(false)
      allow(FileUtils).to receive(:mkdir_p).with(path).and_return([path])
      expect(test_module.config_folder_check).to eq(path)
    end

    it 'should not create when config folder exists' do
      allow(File).to receive(:directory?).with(path).and_return(true)
      expect(FileUtils).to_not receive(:mkdir_p)
      expect(test_module.config_folder_check).to eq(nil)
    end
  end

  context '#yml_file_check' do
    let (:file_content) { YAML.load(File.read(Application.aws_config_file_path)) }
    let (:nil_file_content) { nil }
    let (:empty_file_content) { {"access_key_id"=>"", "secret_access_key"=>"", "region"=>""} }

    it 'should perform system exit if file_content = nil' do
      allow(File).to receive(:exists?).with(aws_file).and_return(true)
      allow(File).to receive(:read).with(aws_file).and_return(empty_file_content.to_yaml)
      expect(STDOUT).to receive(:puts).once
      expect { test_module.yml_file_check }.to raise_error(SystemExit)
    end

    it 'should perform system exit after creating file' do
      file = double('file')
      allow(File).to receive(:exists?).with(aws_file).and_return(false)
      expect(File).to receive(:open).with(aws_file, 'w').and_yield(file)
      expect(file).to receive(:puts)
      expect(STDOUT).to receive(:puts).thrice
      expect { test_module.yml_file_check }.to raise_error(SystemExit)
    end
  end

  context '#configure_aws_file' do
    
    it 'should check config folder + aws.yml file' do
      expect(test_module).to receive(:config_folder_check)
      expect(test_module).to receive(:yml_file_check)
      test_module.configure_aws_file
    end
  end
end