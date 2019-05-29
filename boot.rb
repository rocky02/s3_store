require 'aws-sdk-s3'
require 'colorize'
require 'byebug'
Dir.glob(File.join('lib', '**', '*.rb')).each { |file| require_relative "#{file}" }
